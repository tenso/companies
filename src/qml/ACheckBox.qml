import QtQuick 2.9
import QtQuick.Controls 2.2

CheckBox {
    id: control
    property color checkColor: "#000000"
    indicator: Rectangle {
        implicitWidth: 26
        implicitHeight: 26
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        radius: 3
        border.color: tm.border

        Rectangle {
            width: 14
            height: 14
            x: 6
            y: 6
            radius: 2
            color: control.checkColor
            visible: control.checked
        }
    }
}
