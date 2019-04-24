import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Window 2.11
import QtQuick.Layouts 1.11
import QtQuick.Controls.Styles 1.4

import "../CustomControls"

Page {
    id: training_page
    property string tableName: ""
    property int restDuration: 0
    function setModel() {
        trainingModel.setupModel(tableName)
        train_view.model = trainingModel
    }
    function disableWindow(val) {
        train_view.enabled = !val
        training_controls.enabled = !val
    }

    ListView {
        id: train_view
        anchors.fill: parent
        anchors.margins: 10
        spacing: 30
        delegate: Loader {
            id: train_view_item
            width: parent.width
            height: training_page.height / 10
            sourceComponent: switch (model.isRootRole) {
                             case true:
                                 return exersiceDelegate
                             case false:
                                 return repeatsDelegate
                             }

            Component {
                id: exersiceDelegate
                Column {
                    spacing: 5
                    Row {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 5
                        width: parent.width
                        height: parent.height / 2
                        spacing: 10
                        Image {
                            id: indicator_icon
                            anchors.left: parent.left
                            height: parent.height
                            width: parent.width / 10
                            source: model.haschildRole ? model.isopenRole ? "qrc:/Icons/minus" : "qrc:/Icons/plus" : " "
                            fillMode: Image.PreserveAspectFit
                            horizontalAlignment: Image.AlignLeft
                        }
                        Text {
                            height: parent.height
                            anchors.left: indicator_icon.right
                            anchors.right: menu_icon.left
                            text: model.exerRole
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            wrapMode: Text.Wrap
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    model.isopenRole ? trainingModel.closeItem(
                                                           index) : trainingModel.openItem(
                                                           index)
                                }
                            }
                        }
                        Image {
                            id: menu_icon
                            height: parent.height
                            width: parent.width / 10
                            source: "qrc:/Icons/drawer"
                            fillMode: Image.PreserveAspectFit
                            horizontalAlignment: Image.AlignHCenter
                            anchors.right: parent.right
                            MouseArea {
                                anchors.fill: parent
                                onClicked: repeat_menu.open()
                            }

                            CustomMenu {
                                id: repeat_menu
                                width: training_page.width / 3
                                height: training_page.height / 10
                                MenuItem {
                                    width: repeat_menu.width
                                    height: repeat_menu.height / 2
                                    text: qsTr("Добавить подход")
                                    onClicked: trainingModel.addRepeat(index)
                                }
                                MenuItem {
                                    width: repeat_menu.width
                                    height: repeat_menu.height / 2
                                    text: qsTr("Удалить подход")
                                    onClicked: {
                                        trainingModel.removeRepeat(index)
                                    }
                                }
                            }
                        }
                    }

                    Row {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 10
                        width: parent.width
                        height: parent.height / 2

                        Text {
                            id: repeat_lbl
                            anchors.left: parent.left
                            anchors.leftMargin: 50
                            height: parent.height
                            text: "повторение х"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        CustomComboBox {
                            id: repeat_combo
                            anchors.left: repeat_lbl.right
                            anchors.leftMargin: 10
                            width: parent.width / 4
                            height: parent.height
                            model: [1, 2, 5, 10, 15, 20]
                            onCurrentIndexChanged: {
                                trainingModel.setRepeatIncr(
                                            model[currentIndex], index)
                            }
                        }

                        Text {
                            id: weight_lbl
                            anchors.left: repeat_combo.right
                            anchors.leftMargin: 50
                            height: parent.height
                            text: qsTr("вес х")
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        CustomComboBox {
                            id: weight_combo
                            height: parent.height
                            width: parent.width / 4
                            anchors.left: weight_lbl.right
                            anchors.leftMargin: 10
                            model: [0.25, 0.5, 1.0, 1.5, 2, 5, 10]
                            onCurrentIndexChanged: {
                                trainingModel.setWeightIncr(
                                            model[currentIndex], index)
                            }
                        }
                    }
                }
            }
            Component {
                id: repeatsDelegate
                Row {
                    spacing: 20

                    Text {
                        id: repeat_num_lbl
                        anchors.left: parent.left
                        anchors.leftMargin: 50
                        height: parent.height / 2
                        text: model.exerRole
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    CustomSpinBox {
                        id: repeat_spin
                        anchors.left: repeat_num_lbl.right
                        anchors.leftMargin: 50
                        height: parent.height / 2
                        width: parent.width / 3
                        value: model.repeatRole
                        up.onPressedChanged: {
                            if (up.pressed)
                                stepSize = trainingModel.getRepeatIncr(index)
                        }
                        down.onPressedChanged: {
                            if (down.pressed)
                                stepSize = trainingModel.getRepeatIncr(index)
                        }
                        onValueModified: {
                            trainingModel.setRepeat(value, index)
                        }
                    }

                    DSpinBox {
                        id: weight_spin
                        anchors.left: repeat_spin.right
                        anchors.leftMargin: 50
                        height: parent.height / 2
                        width: parent.width / 3
                        value: 100 * model.weightRole
                        up.onPressedChanged: {
                            if (up.pressed)
                                stepSize = 100 * trainingModel.getWeightIncr(
                                            index)
                        }
                        down.onPressedChanged: {
                            if (down.pressed)
                                stepSize = 100 * trainingModel.getWeightIncr(
                                            index)
                        }
                        onValueModified: {
                            trainingModel.setWeight(realValue, index)
                        }
                    }

                    CustomCheckBox {
                        anchors.left: weight_spin.right
                        anchors.leftMargin: 30
                        height: parent.height / 2
                        width: parent.height / 2
                        onCheckStateChanged: {
                            weight_spin.enabled = !checked
                            repeat_spin.enabled = !checked
                        }
                    }
                }
            }
        }
    }

    footer: DialogButtonBox {
        id: training_controls
        height: parent.height / 8
        width: parent.width
        Button {
            text: qsTr("Начать отдых")
            DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
            onClicked: {
                if (restTimer.visible)
                    return
                restTimer.visible = true
                restTimer.startRest()
            }
        }
        Button {
            text: qsTr("Закончить тренировку")
            DialogButtonBox.buttonRole: DialogButtonBox.ApplyRole
            onClicked: {
                trainingModel.saveToBase(tableName)
                startTrain.updateLastTrainig()
                stackView.pop(null)
            }
        }
    }
    RestTimer {
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width / 2
        height: parent.height / 3
        id: restTimer
        duration: restDuration
        visible: false
        onVisibleChanged: {
            mainWindow.disableToolBar(visible)
            training_page.disableWindow(visible)
        }
    }
}
