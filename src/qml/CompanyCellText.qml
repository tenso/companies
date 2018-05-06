import QtQuick 2.9

Item {
    height: parent.height
    width: 100
    property alias text: input.text
    property alias color: input.color
    property alias font: input.font
    property alias horizontalAlignment: input.horizontalAlignment
    property int pad: 12
    clip: true
    Text {
        id: input
        clip: true
        anchors.fill: parent
        anchors.leftMargin: parent.pad
        maximumLineCount: 1
        verticalAlignment: Text.AlignVCenter
        font: tm.font
    }
}
