import QtQuick 2.9

AItem {
    id: scope
    property alias enabled: input.enabled
    property alias text: input.text
    property alias font: input.font
    property color color: tm.editBg(enabled)
    readonly property color visibleColor: box.color
    signal updated(string text)

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
            text: model ? model[role] : ""
            onTextEdited: {
                if (model && role !== "") {
                    model[role] = text;
                    logStatus("id:" + model.id + " " + role + "=" + text);
                }
                scope.updated(text);
            }
            verticalAlignment: Text.AlignVCenter
            color: tm.editFg(parent.enabled)
            clip: true
            anchors.fill: parent
            anchors.leftMargin: 12
            font: tm.font
        }
    }
}
