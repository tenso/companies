import QtQuick 2.9

AItem {
    Theme {id:tm}

    id: dataRow
    height: tm.rowH * 10

    Rectangle {
        id: bg
        anchors.fill: parent
        color: "transparent"

        Text {
            width: tm.colW
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: tm.margin * 2
            anchors.topMargin: tm.margin
            text: itemData ? "(" + itemData.id + ")" : ""
        }
    }

    CompanyDetailGroup {
        id: basics
        itemData: dataRow.itemData
        groupName: "Basics"
        headerModel: [qsTr("Year"), qsTr("Quarter"), qsTr("Shares"), qsTr("Share Price")]
        itemRoles:  ["year", "qId", "shares", "sharePrice"]
        itemCombos: { "qId": quartersModel }
        prevFocus: leasing.lastFocusItem
    }

    CompanyDetailGroup {
        id: income
        itemData: dataRow.itemData
        anchors.top: basics.top
        anchors.left: equity.left

        groupName: "Income & expenses"
        headerModel: [qsTr("Sales"), qsTr("Ebit"), qsTr("Dividend"), qsTr("Remuneration"),
            qsTr("Interest payed"), qsTr("Debt maturity")]
        itemRoles:  ["sales", "ebit", "dividend", "managRemun",  "interestPayed", "debtMaturity"]
        prevFocus: basics.lastFocusItem
    }

    CompanyDetailGroup {
        id: assets
        itemData: dataRow.itemData
        anchors.top: basics.bottom
        anchors.left: basics.left
        anchors.topMargin: 0
        groupName: "Assets"
        headerModel: [qsTr("Fixed"), qsTr("Fixed: PPE"), qsTr("Current"), qsTr("Current: Cash")]
        itemRoles:  ["assetsFixed", "assetsFixedPpe", "assetsCurr", "assetsCurrCash"]
        prevFocus: income.lastFocusItem
    }

    CompanyDetailGroup {
        id: equity
        itemData: dataRow.itemData
        anchors.top: assets.top
        anchors.left: assets.right
        anchors.leftMargin: tm.rowH * 2
        groupName: "Equity"
        headerModel: [qsTr("Equity")]
        itemRoles:  ["equity"]
        prevFocus: assets.lastFocusItem
    }

    CompanyDetailGroup {
        id: liabilities
        itemData: dataRow.itemData
        anchors.top: assets.bottom
        anchors.left: assets.left
        anchors.topMargin: 0
        groupName: "Liabilities"
        headerModel: [qsTr("Long"), qsTr("Long: Intb."), qsTr("Current"), qsTr("Current: Intb.")]
        itemRoles:  ["liabLong", "liabLongInt", "liabCurr", "liabCurrInt"]
        prevFocus: equity.lastFocusItem
    }

    CompanyDetailGroup {
        id: leasing
        itemData: dataRow.itemData
        anchors.top: liabilities.top
        anchors.left: equity.left
        groupName: "Leasing"
        headerModel: [qsTr("This y."), qsTr("+1"), qsTr("+2-5"), qsTr("+5")]
        itemRoles:  ["leasingY", "leasingY1", "leasingY2Y5", "leaingY5Up"]
        prevFocus: leasing.lastFocusItem
    }

}
