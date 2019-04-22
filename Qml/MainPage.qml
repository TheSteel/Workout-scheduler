import QtQuick 2.11
import QtQuick.Window 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11

import "Scheduler"
import "Learn"
import "Train"

ApplicationWindow {
    function disableToolBar(val) {
        backButton.enabled = !val
        settingsButton.enabled = !val
    }
    id: mainWindow
    title: qsTr("Журнал Тренировок")

    color: "lightgray"
    visible: true
    header: ToolBar {
        id: header_
        height: parent.height / 10
        width: parent.width
        RowLayout {
            spacing: 20
            anchors.fill: parent
            ToolButton {
                id: backButton
                Layout.alignment: Qt.AlignLeft
                Layout.preferredWidth: header_.width / 5
                Layout.preferredHeight: header_.height
                icon.source: stackView.depth > 1 ? "qrc:/Icons/back" : ""
                icon.height: header_.height
                icon.width: header_.width / 6
                onClicked: {
                    if (stackView.depth > 1) {
                        stackView.pop()
                        if (stackView.depth === 1)
                            mainWindow.setTitle(qsTr("Журнал Тренировок"))
                    }
                }
            }
            Text {
                text: mainWindow.title.toString()
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Label.ElideMiddle
                Layout.preferredWidth: header_.width - settingsButton.width - backButton.width
                Layout.preferredHeight: header_.height
                wrapMode: Text.Wrap
            }
            ToolButton {
                id: settingsButton
                Layout.alignment: Qt.AlignRight
                Layout.preferredWidth: header_.width / 5
                Layout.preferredHeight: header_.height
                icon.source: "qrc:/Icons/menu"
                icon.height: header_.height
                icon.width: header_.width / 5
            }
        }
    }

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: Pane {
            id: mainMenu
            ColumnLayout {
                spacing: mainWindow.height / 16
                anchors.centerIn: parent
                RoundButton {
                    radius: parent.width / 5
                    Layout.preferredWidth: Math.round(mainWindow.width / 2)
                    Layout.preferredHeight: Math.round(mainWindow.height / 8)
                    text: qsTr("Тренировка")
                    onClicked: {
                        stackView.push(startTrain)
                        mainWindow.setTitle(qsTr("Тренировка"))
                    }
                }
                RoundButton {
                    radius: parent.width / 5
                    Layout.preferredWidth: Math.round(mainWindow.width / 2)
                    Layout.preferredHeight: Math.round(mainWindow.height / 8)
                    text: qsTr("Редактор")
                    onClicked: {
                        stackView.push(programmList)
                        mainWindow.setTitle(qsTr("Редактор"))
                    }
                }
                RoundButton {
                    radius: parent.width / 5
                    Layout.preferredWidth: Math.round(mainWindow.width / 2)
                    Layout.preferredHeight: Math.round(mainWindow.height / 8)
                    text: qsTr("Справочник")
                    onClicked: {
                        stackView.push(learnPage)
                        mainWindow.setTitle(qsTr("Справочник"))
                    }
                }
                RoundButton {
                    radius: parent.width / 5
                    Layout.preferredWidth: Math.round(mainWindow.width / 2)
                    Layout.preferredHeight: Math.round(mainWindow.height / 8)
                    text: qsTr("Выход")
                    onClicked: Qt.quit()
                }
            }
        }
    }
    ProgrammList {
        id: programmList
        visible: false
    }
    LearnMain {
        id: learnPage
        visible: false
    }
    StartTrain {
        id: startTrain
        visible: false
    }
}
