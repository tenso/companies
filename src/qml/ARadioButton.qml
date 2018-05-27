import QtQuick 2.9
import QtQuick.Controls 2.2

RadioButton {
    Theme{id:tm}
    id: control
    width: 30
    height: 30

    indicator: Rectangle {
        width: control.width * 0.8
        height: control.height * 0.8
        anchors.centerIn: control
        radius: width / 2
        color: tm.focusBg
        visible: control.checked
    }

    background: Rectangle {
        color: "transparent"
        anchors.centerIn: parent
        width: control.width
        height: control.height
        radius: width / 2
        border.color: tm.headBg
        border.width: 1
    }
}
