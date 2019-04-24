import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Window 2.11
import QtQuick.Layouts 1.11
import QtQuick.Controls.Styles 1.4

import "../CustomControls"

Page {
    id: progList
    header: Text {
        text: qsTr("Программы")
        font.family: "Monotype Corsiva"
        font.bold: true
        font.pointSize: 14
        horizontalAlignment: Text.AlignHCenter
    }

    ListView {
        id: list_view
        anchors.fill: parent
        anchors.margins: 30
        model: listModel
        spacing: parent.width / 30

        delegate: Item {
            id: list_item
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 5
            height: progList.height / 10
            Rectangle {
                anchors.fill: parent
                radius: 30
                color: "lightgreen"
                border.width: 3
                border.color: "darkslateblue"
            }
            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                Text {
                    Layout.leftMargin: 5
                    id: list_item_name
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                    text: model.nameRole
                }
                Button {
                    id: list_item_button
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignRight
                    Layout.preferredWidth: parent.width / 5
                    Layout.rightMargin: 5
                    flat: true
                    onClicked: {
                        list_item_menu.open()
                    }
                    Image {
                        anchors.fill: parent
                        source: "qrc:/Icons/drawer"
                        fillMode: Image.PreserveAspectFit
                    }
                    CustomMenu {
                        id: list_item_menu
                        width: progList.width / 3
                        height: progList.height / 10
                        MenuItem {
                            text: qsTr("Редактировать")
                            width: list_item_menu.width
                            height: list_item_menu.height / 2
                            onClicked: {
                                trainList.parentTable = "programm_" + model.nameRole
                                trainList.name = model.nameRole
                                setupModel()
                                stackView.push(trainList)
                            }
                        }
                        MenuItem {
                            width: list_item_menu.width
                            height: list_item_menu.height / 2
                            text: qsTr("Удалить")
                            onClicked: {
                                listModel.removeItem(index)
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
        anchors.bottomMargin: 100
        anchors.rightMargin: 100
        onClicked: {
            progDialog.open()
        }
    }

    Dialog {
        id: progDialog
        closePolicy: Popup.NoAutoClose
        implicitWidth: Math.round(parent.width / 2)
        implicitHeight: Math.round(parent.height / 6)
        x: Math.round(parent.width / 2 - width / 2)
        y: Math.round(parent.height / 2 - height / 2)

        onAboutToShow: {
            inputName.placeholderText = qsTr("Введите название программы")
        }
        onVisibleChanged: {
            mainWindow.disableToolBar(visible)
            list_view.enabled = !visible
        }

        TextField {
            anchors.fill: parent
            id: inputName
            focus: true
            wrapMode: Text.WordWrap
            validator: RegExpValidator {
                regExp: /[\w ]+/
            }
        }

        standardButtons: DialogButtonBox.Apply | DialogButtonBox.Cancel
        onApplied: {
            if (inputName.text.length)
                if (listModel.addItem(inputName.text.toString()))
                    startTrain.updateProgrammInfo()
            inputName.clear()
            progDialog.close()
        }
        onRejected: {
            progDialog.close()
        }
    }
    TrainDayList {
        id: trainList
    }
    signal setupModel
    onSetupModel: trainList.setModel()
}
