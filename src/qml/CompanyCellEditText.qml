import QtQuick 2.2

Rectangle {
    height: parent.height
    width: 100
    color: enabled ? "#87b4ff" : "#ffffff"
    signal editingFinished()
    property alias enabled: input.enabled
    property alias text: input.text

    TextInput {
        id: input
        onEditingFinished: parent.editingFinished
        verticalAlignment: Text.AlignVCenter
        clip: true
        anchors.fill: parent
        font.pixelSize: 18
    }
}
