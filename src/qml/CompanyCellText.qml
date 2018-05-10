import QtQuick 2.9

Item {
    Theme {id:tm}
    property alias text: input.text
    property alias color: input.color
    property alias font: input.font
    property alias horizontalAlignment: input.horizontalAlignment
    property alias verticalAlignment: input.verticalAlignment
    property alias maximumLineCount: input.maximumLineCount

    width: 100
    height: tm.rowH
    clip: true

    Text {
        id: input
        clip: true
        wrapMode: Text.Wrap
        anchors.fill: parent
        maximumLineCount: 1
        verticalAlignment: Text.AlignVCenter
        font: tm.font
    }
}
