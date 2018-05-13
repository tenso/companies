import QtQuick 2.9
import QtQuick.Controls 2.2

AButton {
    Theme {id: tm}
    id: root
    property variant model
    property variant view
    property int addId: -1
    property string addIdRole: ""
    signal willCreate();
    signal willDelete(int id);
    property bool active: false


    height: tm.rowH
    width: tm.colW
    text: qsTr("Data")
    onClicked: menu.open()
    font: tm.font

    Shortcut {
        sequence: "Ctrl+N"
        enabled: root.active
        onActivated: {
            if (root.enabled && add.enabled) {
                newEntry();
            }
        }
    }
    Shortcut {
        sequence: "Ctrl+D"
        enabled: root.active
        onActivated: {
            if (root.enabled && del.enabled) {
                delEntry();
            }
        }
    }


    function newEntry() {
        willCreate();
        if (model) {
            if (!model.newRow(addIdRole, addId)){
                logError("new row failed cId=" + addId);
            }
            else {
                logStatus("added row for cId=" + addId);
            }
        }
    }

    function delEntry() {
        var row = view.currentIndex;
        if (model) {
            willDelete(model.rowToId(row));
            if (!model.delRow(row)) {
                logError("del row failed " + row + " for " + addId);
            }
            else {
                logStatus("removed row " + row + " for " + addId);
            }
        }
        else {
            willDelete(-1);
        }

        var newIndex = view.currentIndex;
        if (row >= view.count) {
            view.currentIndex = row - 1;
        }
        view.positionViewAtIndex(view.currentIndex, ListView.Beginning);
    }

    Menu {
        id: menu

        MenuItem {
            id: add
            font: tm.font
            text: qsTr("New entry")
            ToolTip {
                font: tm.font
                text: qsTr("Ctrl+N")
                delay: 500
                visible: parent.hovered
            }
            onTriggered: newEntry()
        }

        MenuItem {
            id: del
            font: tm.font
            text: qsTr("Remove entry")
            enabled: view ? (view.currentIndex >= 0) : 0
            ToolTip {
                font: tm.font
                text: qsTr("Ctrl+D")
                delay: 500
                visible: parent.hovered
            }
            onTriggered: delEntry()
        }
    }
}

