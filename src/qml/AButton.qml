import QtQuick 2.9
import QtQuick.Controls 2.2

Button {
    Theme {id:tm}
    id: control
    text: ""
    font: tm.buttonFont

    contentItem: Text {
        text: control.text
        font: control.font
        color: control.down ? "#888888" : "#000000"
        opacity: control.enabled ? 1 : 0.5
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        border.color: control.down ? "#aaaaaa" : "#888888"
        border.width: 1
    }
}
