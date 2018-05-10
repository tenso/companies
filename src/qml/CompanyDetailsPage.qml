import QtQuick 2.9
import QtQuick.Controls 2.2

Page {
    id: page
    Theme {id:tm}
    property alias selectedData: currentCompany.itemData
    property alias rowCount: view.count
    property variant colW: []


    Rectangle {
        id: head
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: tm.rowH + tm.margin * 2
        color: tm.headBg

        CompanyHeaderDeligate {
            id: listHead
            width: page.width
            colW: page.colW
            x: tm.margin
            y: tm.margin
            itemData: [qsTr("Id"), qsTr("Name"), qsTr("List"), qsTr("Type"), qsTr("Watch"), qsTr("Description")]
        }

        AListRow {
            id: currentCompany
            roles:  ["id", "name", "lId", "tId", "watch", "description"]
            comboModels: { "lId": listsModel, "tId": typesModel }
            itemData: overview.currentItemData
            anchors.left: parent.left
            anchors.leftMargin: tm.margin
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: tm.margin
            showEdit: true
            colW: page.colW
            onItemDataChanged: {
                if (itemData) {
                    financialsModel.filterColumn(1, "=" + itemData.id);
                }
            }
        }
    }
    Row {
        id: controls
        anchors.top: head.bottom
        spacing: tm.margin
        AButton {
            id: newButton
            height: tm.rowH
            text: qsTr("New entry")
            onPressed: {
                var cId = currentCompany.itemData.id;
                if (!financialsModel.newRow(1, cId)){
                    logError("new row failed cId=" + cId);
                }
                else {
                    logStatus("added row for cId=" + cId);
                }
            }
        }
        AButton {
            id: delButton
            height: tm.rowH
            text: qsTr("Remove entry")
            enabled: view.currentIndex >= 0
            onPressed: {
                var cId = currentCompany.itemData.id;
                var row = view.currentIndex;
                if (!financialsModel.delRow(row)) {
                    logError("del row failed " + row + " for " + cId);
                }
                else {
                    var newIndex = view.currentIndex;
                    if (row >= view.count) {
                        view.currentIndex = row - 1;
                    }
                    view.positionViewAtIndex(view.currentIndex, ListView.Beginning);
                    logStatus("removed row " + row + " for " + cId);
                }
            }
        }
    }
    Rectangle {
        id: financials
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: controls.bottom
        height: tm.rowH * 10 + view.spacing
        color: tm.headBg

        AList {
            id: view
            model: financialsModel
            anchors.fill: parent
            snapMode: ListView.SnapToItem
            //spacing: tm.margin
            delegate: CompanyDetailsDeligate {
                width: view.width
                itemData: model

                onSelect: {
                    view.currentIndex = index;
                }
            }
        }
    }
}
