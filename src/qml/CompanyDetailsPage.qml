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
        height: tm.rowH * 11 + 10
        anchors.topMargin: tm.rowH
        color: tm.inActive

        AList {
            id: view
            model: financialsModel
            anchors.fill: parent
            snapMode: ListView.SnapToItem
            spacing: 10
            delegate: AItem {
                id: dataRow
                itemData: model
                height: tm.rowH * 2 * 6
                width: view.width

                onSelect: {
                    view.currentIndex = index;
                }

                Rectangle {
                    id: bg
                    anchors.fill: parent
                    color: tm.inActive
                }

                CompanyDetailGroup {
                    id: basics
                    groupName: "Basics"
                    headerModel: [qsTr("Year"), qsTr("Quarter"), qsTr("Shares")]
                    itemRoles:  ["year", "qId", "shares"]
                    itemCombos: { "qId": quartersModel }
                }

                CompanyDetailGroup {
                    id: income
                    anchors.top: basics.top
                    anchors.left: equity.left

                    groupName: "Income & expenses"
                    headerModel: [qsTr("Sales"), qsTr("Ebit"), qsTr("Dividend"), qsTr("Remuneration"),
                        qsTr("Interest payed"), qsTr("Debt maturity")]
                    itemRoles:  ["sales", "ebit", "dividend", "managRemun",  "interestPayed", "debtMaturity"]
                }

                CompanyDetailGroup {
                    id: assets
                    anchors.top: basics.bottom
                    anchors.left: basics.left
                    anchors.topMargin: 0
                    groupName: "Assets"
                    headerModel: [qsTr("Fixed"), qsTr("PPE"), qsTr("Current"), qsTr("Cash")]
                    itemRoles:  ["assetsFixed", "assetsFixedPpe", "assetsCurr", "assetsCurrCash"]
                }

                CompanyDetailGroup {
                    id: equity
                    anchors.top: assets.top
                    anchors.left: assets.right
                    anchors.leftMargin: tm.rowH * 2
                    groupName: "Equity & Liab."
                    headerModel: [qsTr("Equity"), qsTr("Longterm"), qsTr("Intb. long"), qsTr("Current"), qsTr("Intb. current")]

                    itemRoles:  ["equity", "liabLong", "liabLongInt", "liabCurr", "liabCurrInt"]
                }

                CompanyDetailGroup {
                    id: leasing
                    anchors.top: assets.bottom
                    anchors.left: assets.left
                    anchors.topMargin: 0
                    groupName: "Leasing"
                    headerModel: [qsTr("This y."), qsTr("+1"), qsTr("+2-5"), qsTr("+5")]
                    itemRoles:  ["leasingY", "leasingY1", "leasingY2Y5", "leaingY5Up"]
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
