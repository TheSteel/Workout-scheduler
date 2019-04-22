import QtQuick 2.12
import QtQuick.Controls 2.5

SpinBox {
    id: spinbox
    from: 1
    to: 1000 * 100
    property int decimals: 2
    property real realValue: value / 100
    editable: false

    contentItem: Text {
        z: 2
        text: spinbox.textFromValue(spinbox.value, spinbox.locale)
        font.pixelSize: spinbox.font.pixelSize * 1.5
        color: "#21be2b"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    up.indicator: Rectangle {
        x: spinbox.mirrored ? 0 : parent.width - width
        height: parent.height
        width: parent.width / 4
        implicitHeight: 50
        implicitWidth: 50
        border.color: spinbox.enabled ? "#21be2b" : "#bdbebf"
        color: spinbox.up.pressed ? "#e4e4e4" : "#f6f6f6"
        Text {
            text: "+"
            font.pixelSize: spinbox.font.pixelSize * 2
            color: "#21be2b"
            anchors.fill: parent
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    down.indicator: Rectangle {
        x: spinbox.mirrored ? parent.width - width : 0
        height: parent.height
        width: parent.width / 4
        implicitHeight: 50
        implicitWidth: 50
        border.color: spinbox.enabled ? "#21be2b" : "#bdbebf"
        color: spinbox.down.pressed ? "#e4e4e4" : "#f6f6f6"
        Text {
            text: "-"
            font.pixelSize: spinbox.font.pixelSize * 3
            color: "#21be2b"
            anchors.fill: parent
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    validator: DoubleValidator {
        bottom: Math.min(spinbox.from, spinbox.to)
        top: Math.max(spinbox.from, spinbox.to)
    }

    textFromValue: function (value, locale) {
        return Number(value / 100).toLocaleString(locale, 'f', spinbox.decimals)
    }

    valueFromText: function (text, locale) {
        return Number.fromLocaleString(locale, text) * 100
    }
}
