import QtQuick 2.2

Rectangle {
    height: parent.height
    width: 100
    color: enabled ? "#b0c4e5" : "#ffffff"
    signal editingFinished()
    property alias enabled: input.enabled
    property alias text: input.text

    TextInput {
        id: input
        onEditingFinished: parent.editingFinished();
        verticalAlignment: Text.AlignVCenter
        clip: true
        anchors.fill: parent
        font.pixelSize: 18
    }
}
