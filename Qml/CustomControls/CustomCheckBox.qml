import QtQuick 2.12
import QtQuick.Controls 2.5

CheckBox {
    id: checkBox
    checked: false

    indicator: Rectangle {
        implicitWidth: parent.width
        implicitHeight: parent.height
        radius: width / 3
        border.color: checkBox.down ? "#17a81a" : "#21be2b"

        Rectangle {
            width: parent.width / 2
            height: parent.height / 2
            radius: width / 3
            anchors.centerIn: parent

            color: checkBox.down ? "#17a81a" : "#21be2b"
            visible: checkBox.checked
        }
    }
}
