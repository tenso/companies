import QtQuick 2.9

AItem {
    id: root
    Theme {id:tm}
    property alias text: input.text
    property alias font: input.font
    property color color: getColor()
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
            text: root.formatIn(itemData ? itemData[role] : "")
            enabled: root.showEdit
            onEditingFinished: {
                if (itemData && role !== "") {
                    logStatus("id:" + itemData.id + " " + role + "=" + text);
                    itemData[role] = root.formatOut(text); //this will clear itemData...
                }
                else {
                    root.updated(text);
                }
            }
            verticalAlignment: Text.AlignVCenter
            color: root.fontColor
            clip: true
            anchors.fill: parent
            anchors.leftMargin: 12
            font: tm.font
        }
    }
}
