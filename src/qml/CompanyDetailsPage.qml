import QtQuick 2.9
import QtQuick.Controls 2.2

Page {
    id: page
    Theme {id:tm}
    property alias selectedData: currentCompany.itemData
    property alias rowCount: view.count
    property variant colW: []

    CompanyHeaderDeligate {
        id: listHead
        width: page.width
        colW: page.colW
        itemData: [qsTr("Id"), qsTr("Name"), qsTr("List"), qsTr("Type"), qsTr("Watch"), qsTr("Description")]
    }
    Rectangle {
        id: company
        anchors.top: listHead.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: tm.rowH + 10
        color: tm.headBg
        AListRow {
            id: currentCompany
            roles:  ["id", "name", "lId", "tId", "watch", "description"]
            comboModels: { "lId": listsModel, "tId": typesModel }
            itemData: overview.currentItemData
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            showEdit: true
            colW: page.colW
            onItemDataChanged: {
                if (itemData) {
                    financialsModel.filterColumn(1, "=" + itemData.id);
                }
            }
        }
    }
    Rectangle {
        id: financials
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: company.bottom
        height: tm.rowH * 10 + view.spacing
        anchors.topMargin: tm.rowH
        color: tm.headBg

        AList {
            id: view
            model: financialsModel
            anchors.fill: parent
            snapMode: ListView.SnapToItem
            spacing: 4
            delegate: CompanyDetailsDeligate {
                width: view.width
                onSelect: {
                    view.currentIndex = index;
                }
            }
        }
    }
    AButton {
        id: newButton
        anchors.top: financials.bottom
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
        anchors.left: newButton.right
        anchors.top: newButton.top
        anchors.leftMargin: tm.rowH
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
