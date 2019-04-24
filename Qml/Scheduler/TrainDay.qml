import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Window 2.11
import QtQuick.Layouts 1.11
import QtQuick.Controls.Styles 1.4

import "../CustomControls"

Page {
    id: trainDayPage
    property string parentTable: ""
    property string name: ""
    function setModel() {
        dataBase.createTrainDayTable(parentTable)
        exerModel.setupModel(parentTable, 2)
        day_view.model = exerModel
    }
    onFocusChanged: {
        if (!focus && !exerModel.rowCount())
            dataBase.dropTable(parentTable)
    }

    header: Text {
        text: name
        font.family: "Monotype Corsiva"
        font.bold: true
        font.pointSize: 14
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
    }
    ListView {
        id: day_view
        anchors.fill: parent
        anchors.margins: 15
        spacing: 30
        delegate: Item {
            id: day_item
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 5
            height: trainDayPage.height / 10
            Rectangle {
                anchors.fill: parent
                radius: 30
                color: "lightgreen"
                border.width: 3
                border.color: "darkslateblue"
            }

            RowLayout {
                anchors.fill: parent
                spacing: 5
                anchors.margins: 15
                ColumnLayout {
                    Layout.preferredHeight: parent.height
                    Text {
                        id: day_item_name
                        //Layout.preferredHeight: 20
                        Layout.alignment: Qt.AlignLeft
                        text: model.nameRole
                    }
                    Text {
                        id: day_item_repeats
                        //Layout.preferredHeight: 20
                        Layout.alignment: Qt.AlignLeft
                        text: qsTr("Повторения: ") + model.repeatRole
                    }
                    Text {
                        id: day_item_weight
                        //Layout.preferredHeight: 20
                        Layout.alignment: Qt.AlignLeft
                        text: qsTr("Вес: ") + model.weightRole
                    }
                }
                Button {
                    id: day_item_button
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    Layout.preferredWidth: parent.width / 5
                    flat: true
                    onClicked: {
                        day_item_menu.open()
                    }
                    Image {
                        anchors.fill: parent
                        source: "qrc:/Icons/drawer"
                        fillMode: Image.PreserveAspectFit
                    }
                    CustomMenu {
                        id: day_item_menu
                        width: trainDayPage.width / 3
                        height: trainDayPage.height / 10
                        MenuItem {
                            width: day_item_menu.width
                            height: day_item_menu.height / 2
                            text: qsTr("Редактировать")
                            onClicked: {

                            }
                        }
                        MenuItem {
                            width: day_item_menu.width
                            height: day_item_menu.height / 2
                            text: qsTr("Удалить")
                            onClicked: {
                                exerModel.removeItem(index, parentTable)
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

            exerDialog.open()
        }
    }

    Dialog {
        id: exerDialog
        closePolicy: Popup.NoAutoClose
        implicitWidth: parent.width
        implicitHeight: parent.height
        onVisibleChanged: {
            mainWindow.disableToolBar(visible)
            day_view.enabled = !visible
        }
        Column {
            spacing: 30
            anchors.fill: parent
            anchors.margins: 30
            Text {
                id: muscle_lbl
                width: parent.width
                height: parent.height / 15
                text: qsTr("Мышечная группа")
                horizontalAlignment: Text.AlignHCenter
            }
            CustomComboBox {
                id: mscl_combo
                width: parent.width
                height: parent.height / 15
                model: dataBase.getMuscleGroups()
                onCurrentTextChanged: {
                    exerListBox.model = dataBase.getExerList(currentText)
                }
            }
            Text {
                id: exer_lbl
                width: parent.width
                height: parent.height / 15
                text: qsTr("Упражнение")
                horizontalAlignment: Text.AlignHCenter
            }
            CustomComboBox {
                id: exerListBox
                width: parent.width
                height: parent.height / 15
            }
            Text {
                id: weight_text
                width: parent.width
                height: parent.height / 15
                text: qsTr("Вес")
                horizontalAlignment: Text.AlignHCenter
            }
            TextField {
                id: weightList
                height: parent.height / 15
                width: parent.width
                property int len: 0
                readOnly: true
            }
            Text {
                id: approach_text
                height: parent.height / 15
                width: parent.width
                text: qsTr("Подход")
                horizontalAlignment: Text.AlignHCenter
            }
            TextField {
                id: repeatList
                height: parent.height / 15
                width: parent.width
                property int len: 0
                readOnly: true
            }
            Row {
                anchors.top: repeatTumb.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                width: exerDialog.width
                height: exerDialog.height / 5
                Text {
                    id: weight_lbl
                    anchors.left: parent.left
                    anchors.leftMargin: 50
                    text: qsTr("В\nе\nс")
                    verticalAlignment: Text.AlignVCenter
                    height: parent.height
                    width: parent.width / 10
                }
                CustomTumbler {
                    id: weightTumb
                    anchors.left: weight_lbl.right
                    anchors.leftMargin: 20
                    model: 500
                    suffix: qsTr("кг")
                    height: parent.height
                    width: parent.width / 8
                }
                Text {
                    id: repeat_lbl
                    anchors.left: weightTumb.right
                    anchors.leftMargin: 50
                    text: qsTr("П\nо\nв\nт\nо\nр")
                    verticalAlignment: Text.AlignVCenter
                    height: parent.height
                    width: parent.width / 10
                }
                CustomTumbler {
                    id: repeatTumb
                    anchors.left: repeat_lbl.right
                    anchors.leftMargin: 20
                    model: 500
                    height: parent.height
                    width: parent.width / 8
                }
                Column {
                    id: repeatButtons
                    spacing: 15
                    width: parent.width / 4
                    height: parent.height
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    Button {
                        text: "+"
                        width: parent.width
                        height: parent.height / 3
                        onClicked: {
                            var pos = weightList.length
                            weightList.len = weightList.length
                            weightList.insert(
                                        pos,
                                        pos ? ", "
                                              + weightTumb.currentIndex : weightTumb.currentIndex)
                            pos = repeatList.length
                            repeatList.len = repeatList.length
                            repeatList.insert(
                                        pos,
                                        pos ? ", "
                                              + repeatTumb.currentIndex : repeatTumb.currentIndex)
                        }
                    }
                    Button {
                        text: "-"
                        width: parent.width
                        height: parent.height / 3
                        onClicked: {
                            weightList.remove(weightList.len, weightList.length)
                            repeatList.remove(repeatList.len, repeatList.length)
                        }
                    }
                    Button {
                        width: parent.width
                        height: parent.height / 3
                        icon.source: "qrc:/Icons/trash"
                        onClicked: {
                            weightList.clear()
                            repeatList.clear()
                        }
                    }
                }
            }
        }
        standardButtons: DialogButtonBox.Apply | DialogButtonBox.Cancel
        onApplied: {
            if (exerListBox.currentText.length && weightList.text.length)
                exerModel.addItem(exerListBox.currentText, repeatList.text,
                                  weightList.text, parentTable)
            exerDialog.close()
        }
        onRejected: {
            exerDialog.close()
        }
    }
}
