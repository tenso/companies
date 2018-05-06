import QtQuick 2.9
import QtQuick.Controls 2.2

TabButton {
    Theme {id:tm}
    id: control
    height: parent.height
    font: tm.font
    text: qsTr("ATabButton")

    background: Rectangle {
        anchors.fill: parent
        color: control.checked ? tm.bg : tm.menuBg
    }
}
