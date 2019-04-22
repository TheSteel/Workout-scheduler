import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Controls.Styles 1.4

import CircleTimer 1.0

Item {
    id: timerItem
    property int duration: 0
    function startRest() {
        circleTimer.setDuration(duration)
        circleTimer.start()
    }

    CircleTimer {
        id: circleTimer
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 10
        width: parent.width / 2
        height: parent.width / 2
        backgroundColor: "whiteSmoke"
        borderActiveColor: "LightGray"
        borderNonActiveColor: "LightGreen"

        Text {
            id: textTimer
            anchors.centerIn: parent
        }

        onCircleTimeChanged: textTimer.text = Qt.formatTime(circleTime, "mm:ss")
    }

    DialogButtonBox {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        spacing: 10
        Button {
            text: "Сброс"
            DialogButtonBox.buttonRole: DialogButtonBox.ResetRole
            onClicked: {
                circleTimer.reset()
            }
        }
        Button {
            text: "Стоп"
            DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
            onClicked: {
                circleTimer.stop()
                circleTimer.reset()
                timerItem.visible = false
            }
        }
    }
}
