import QtQuick 2.7

FocusScope {
    id: scope
    property alias enabled: input.enabled
    property alias text: input.text
    property alias font: input.font
    property color color: tm.editBg(enabled)
    readonly property color visibleColor: box.color
    signal updated()

    height: parent.height
    width: 100

    Rectangle {
        id: box
        Theme {id: tm}
        anchors.fill: parent
        color: input.activeFocus ? tm.focusBg : scope.color

        TextInput {
            id: input
            focus: true
            onEditingFinished: scope.updated();
            verticalAlignment: Text.AlignVCenter
            color: tm.editFg(parent.enabled)
            clip: true
            anchors.fill: parent
            anchors.leftMargin: 12
            font: tm.font
        }
    }
}
