import QtQuick 2.9

Row {
    Theme {id: tm}
    id: root
    property variant model
    property variant view
    property int addId: -1
    property int addIdCol: -1
    signal willDelete(int id);

    spacing: tm.margin

    AButton {
        id: newButton
        height: tm.rowH
        text: qsTr("New entry")
        enabled: root.enabled
        onPressed: {
            if (!model.newRow(addIdCol, addId)){
                logError("new row failed cId=" + addId);
            }
            else {
                logStatus("added row for cId=" + addId);
            }
        }
    }
    AButton {
        id: delButton
        height: tm.rowH
        text: qsTr("Remove entry")
        enabled: root.enabled && (view.currentIndex >= 0)
        onPressed: {
            var row = view.currentIndex;
            willDelete(model.rowToId(row));
            if (!model.delRow(row)) {
                logError("del row failed " + row + " for " + addId);
            }
            else {
                var newIndex = view.currentIndex;
                if (row >= view.count) {
                    view.currentIndex = row - 1;
                }
                view.positionViewAtIndex(view.currentIndex, ListView.Beginning);
                logStatus("removed row " + row + " for " + addId);
            }
        }
    }
}
