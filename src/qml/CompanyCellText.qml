import QtQuick 2.0

Item {
    height: parent.height
    width: 100
    property alias text: input.text
    property alias color: input.color
    Text {
        id: input
        clip: true
        anchors.fill: parent
        anchors.leftMargin: 12
        maximumLineCount: 1
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 18
    }
}
