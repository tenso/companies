import QtQuick 2.9

AItem {
    id: root
    Theme {id:tm}
    property alias enabled: input.enabled
    property alias text: input.text
    property alias font: input.font
    property color color: tm.editBg(enabled)
    readonly property color visibleColor: box.color
    signal updated(string text)

    width: 100
    height: tm.rowH

    Rectangle {
        id: box
        anchors.fill: parent
        color: input.activeFocus ? tm.focusBg : root.color

        TextInput {
            id: input
            focus: true
            text: itemData ? itemData[role] : ""
            onEditingFinished: {
                if (itemData && role !== "") {
                    logStatus("id:" + itemData.id + " " + role + "=" + text);
                    itemData[role] = text; //this will clear itemData...
                }
                root.updated(text);
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
