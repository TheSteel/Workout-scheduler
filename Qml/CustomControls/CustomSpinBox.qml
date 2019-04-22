import QtQuick 2.12
import QtQuick.Controls 2.5

SpinBox {
    id: control
    from: 1
    to: 1000
    editable: false
    contentItem: Text {
        z: 2
        text: control.textFromValue(control.value, control.locale)
        font.pixelSize: control.font.pixelSize
        color: "#21be2b"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    up.indicator: Rectangle {
        x: control.mirrored ? 0 : parent.width - width
        height: parent.height
        width: parent.width / 4
        implicitWidth: 50
        implicitHeight: 50
        color: control.up.pressed ? "#e4e4e4" : "#f6f6f6"
        border.color: enabled ? "#21be2b" : "#bdbebf"

        Text {
            text: "+"
            font.pixelSize: control.font.pixelSize * 3
            color: "#21be2b"
            anchors.fill: parent
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    down.indicator: Rectangle {
        x: control.mirrored ? parent.width - width : 0
        height: parent.height
        width: parent.width / 4
        implicitWidth: 50
        implicitHeight: 50
        color: control.down.pressed ? "#e4e4e4" : "#f6f6f6"
        border.color: enabled ? "#21be2b" : "#bdbebf"

        Text {
            text: "-"
            font.pixelSize: control.font.pixelSize * 3
            color: "#21be2b"
            anchors.fill: parent
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
