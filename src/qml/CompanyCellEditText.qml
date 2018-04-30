import QtQuick 2.7

Rectangle {
    Theme {id: tm}
    height: parent.height
    width: 100
    color: tm.editColor(showEdit)

    signal editingFinished()
    property alias enabled: input.enabled
    property alias text: input.text

    TextInput {
        id: input
        leftPadding: 12
        onEditingFinished: parent.editingFinished();
        verticalAlignment: Text.AlignVCenter
        clip: true
        anchors.fill: parent
        font.pixelSize: 18
    }
}
