import QtQuick 2.6
import QtQuick.Controls 2.1

Button {
    id: control
    text: qsTr("Button")

    contentItem: Text {
        text: control.text
        font: control.font
        color: control.down ? "#888888" : "#000000"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        border.color: control.down ? "#aaaaaa" : "#888888"
        border.width: 1
    }
}
