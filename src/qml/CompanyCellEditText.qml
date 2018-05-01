import QtQuick 2.7

Rectangle {
    Theme {id: tm}
    height: parent.height
    width: 100
    color: tm.editBg(enabled)

    signal editingFinished()
    property alias enabled: input.enabled
    property alias text: input.text
    property alias font: input.font

    TextInput {
        id: input
        onEditingFinished: parent.editingFinished();
        verticalAlignment: Text.AlignVCenter
        color: tm.editFg(parent.enabled)
        clip: true
        anchors.fill: parent
        anchors.leftMargin: 12
        font: tm.font
    }
}
