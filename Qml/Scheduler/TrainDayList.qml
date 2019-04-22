import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Window 2.11
import QtQuick.Layouts 1.11
import QtQuick.Controls.Styles 1.4

import "../CustomControls"

Page {
    id: trainDayListPage
    property string parentTable: ""
    property string name: ""
    function setModel() {
        dataBase.createProgrammDaysTable(parentTable)
        dayModel.setupModel(parentTable, 1)
        train_view.model = dayModel
    }
    onFocusChanged: {
        if (!focus && !dayModel.rowCount())
            dataBase.dropTable(parentTable)
    }

    header: Text {
        text: name
        font.family: "Monotype Corsiva"
        font.bold: true
        font.pointSize: 14
        horizontalAlignment: Text.AlignHCenter
    }

    ListView {
        id: train_view
        anchors.fill: parent
        anchors.margins: 5
        spacing: 30
        delegate: Item {
            id: train_item
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 5
            height: trainDayListPage.height / 10
            Rectangle {
                anchors.fill: parent
                radius: 30
                color: "lightgreen"
                border.width: 3
                border.color: "darkslateblue"
            }
            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                ColumnLayout {
                    id: col
                    spacing: 20
                    anchors.margins: 5
                    RowLayout {
                        id: row
                        Layout.preferredHeight: parent.height / 2
                        Layout.preferredWidth: parent.width
                        Text {
                            id: train_item_name
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignLeft
                            text: model.nameRole
                        }
                    }
                    Text {
                        Layout.preferredHeight: parent.height / 2
                        Layout.preferredWidth: parent.width
                        Layout.alignment: Qt.AlignLeft
                        text: qsTr("Время отдыха: " + model.minRole + " мин "
                                   + model.secRole + " сек")
                    }
                }
                Button {
                    id: train_item_button
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignRight
                    Layout.preferredWidth: parent.width / 5
                    flat: true
                    onClicked: {
                        train_item_menu.open()
                    }
                    Image {
                        anchors.fill: parent
                        source: "qrc:/Icons/drawer"
                        fillMode: Image.PreserveAspectFit
                    }
                    Menu {
                        id: train_item_menu
                        rightMargin: 30
                        spacing: 5
                        width: trainDayListPage.width / 3
                        height: trainDayListPage.height / 10
                        MenuItem {
                            width: train_item_menu.width
                            height: train_item_menu.height / 2
                            text: qsTr("Редактировать")
                            onClicked: {
                                trainDay.parentTable = parentTable + "_" + model.nameRole
                                trainDay.name = model.nameRole
                                setupModel()
                                stackView.push(trainDay)
                            }
                        }
                        MenuItem {
                            width: train_item_menu.width
                            height: train_item_menu.height / 2
                            text: qsTr("Удалить")
                            onClicked: {
                                dayModel.removeItem(index, parentTable)
                                startTrain.updateProgrammInfo()
                            }
                        }
                    }
                }
            }
        }
    }
    RoundButton {
        text: "+"
        radius: Math.round((parent.width / 6) / 2)
        width: Math.round(parent.width / 6)
        height: Math.round(parent.width / 6)
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        anchors.rightMargin: 50
        onClicked: {
            dayDialog.open()
        }
    }

    Dialog {
        id: dayDialog
        closePolicy: Popup.NoAutoClose
        anchors.centerIn: parent
        implicitWidth: parent.width / 1.5
        implicitHeight: Math.round(parent.height / 3)
        x: Math.round(parent.width / 2 - width / 2)
        y: Math.round(parent.height / 2 - height / 2)
        onVisibleChanged: {
            mainWindow.disableToolBar(visible)
            train_view.enabled = !visible
        }
        onAboutToShow: {
            inputName.placeholderText = qsTr(
                        "Введите название тренировочного дня")
        }
        ColumnLayout {
            spacing: 15
            anchors.fill: parent
            anchors.margins: 5
            TextField {
                Layout.preferredHeight: parent.height / 3
                Layout.preferredWidth: parent.width
                id: inputName
                focus: true
                wrapMode: Text.WordWrap
            }
            RowLayout {
                Layout.preferredHeight: parent.height - inputName.height
                Layout.preferredWidth: parent.width
                id: restTime
                Text {
                    Layout.preferredWidth: parent.width / 2
                    Layout.fillHeight: true
                    text: qsTr("Время отдыха (между подходами): ")
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                }
                CustomTumbler {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredHeight: parent.height
                    id: restMin
                    model: 59
                    suffix: qsTr("мин")
                }
                CustomTumbler {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredHeight: parent.height
                    id: restSec
                    model: 59
                    suffix: qsTr("сек")
                }
            }
        }

        standardButtons: DialogButtonBox.Apply | DialogButtonBox.Cancel
        onApplied: {
            if (inputName.text.length)
                if (dayModel.addItem(inputName.text.toString(),
                                     restMin.currentIndex,
                                     restSec.currentIndex, parentTable))
                    startTrain.updateProgrammInfo()
            inputName.clear()
            dayDialog.close()
        }
        onRejected: {
            dayDialog.close()
        }
    }

    TrainDay {
        id: trainDay
    }

    signal setupModel
    onSetupModel: trainDay.setModel()
}
