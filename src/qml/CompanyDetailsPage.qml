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
        height: tm.rowH + 10
        colW: page.colW
        model: [qsTr("Id"), qsTr("Name"), qsTr("List"), qsTr("Type"), qsTr("Watch"), qsTr("Description")]
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
            height: tm.rowH
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
        anchors.bottom: parent.bottom
        anchors.margins: tm.rowH
        color: tm.menuBg
        property int singleW: 80

        CompanyHeaderDeligate {
            id: financialsHead
            width: parent.width
            height: tm.rowH
            singleW: financials.singleW
            model: [qsTr("Year"), qsTr("Quarter"), qsTr("Shares"), qsTr("Sales"), qsTr("Ebit")]
        }

        AList {
            id: view
            model: financialsModel
            anchors.left: financials.left
            anchors.right: financials.right
            anchors.top: financialsHead.bottom
            anchors.bottom: financials.bottom
            anchors.bottomMargin: newButton.height
            delegate: AListRow {
                roles:  [
                    "year", "qId", "shares", "sales", "ebit", "assetsFixed", "assetsFixedPpe",
                    "assetsCurrent", "assetsCurrentCash", "equity", "liabilitiesLongterm",
                    "liabilitiesLongtermInterestCarrying", "liabilitiesCurrent", "liabilitiesCurrentInterestCarrying",
                    "interestPayed", "dividend"
                ]
                comboModels: { "qId": quartersModel }
                itemData: model
                width: view.width
                height: tm.rowH
                singleW: financials.singleW
                onSelect: {
                    view.currentIndex = index;
                    view.forceActiveFocus();
                }
            }
        }
        AButton {
            id: newButton
            anchors.top: view.bottom
            text: qsTr("New entry")
            onPressed: {
                var cId = currentCompany.itemData.id;
                var row = financialsModel.newRow(1, cId);
                if (row === -1) {
                    logError("new row failed " + cId);
                }
                else {
                    logStatus("added row " + row + " for " + cId);
                }
            }
        }
        AButton {
            id: delButton
            anchors.left: newButton.right
            anchors.top: newButton.top
            anchors.leftMargin: tm.rowH
            text: qsTr("Remove entry")
            onPressed: {
                var cId = currentCompany.itemData.id;
                var row = view.currentIndex;
                if (!financialsModel.delRow(row)) {
                    logError("del row failed " + row + " for " + cId);
                }
                else {
                    logStatus("removed row " + row + " for " + cId);
                }
            }
        }
    }
}
