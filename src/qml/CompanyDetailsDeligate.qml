import QtQuick 2.9

AItem {
    Theme {id:tm}

    id: dataRow
    height: tm.rowH * 10 + separator.height

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
        Rectangle {
            id: separator
            color: tm.headBg
            width: parent.width
            height: 1
            anchors.bottomMargin: tm.margin / 2
            anchors.bottom: parent.bottom
        }
    }

    //row 1
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
        anchors.left: equityAndLiab.left

        groupName: "Income"
        headerModel: [qsTr("Sales"), qsTr("Ebit")]
        itemRoles:  ["sales", "ebit"]
        prevFocus: basics.lastFocusItem
    }

    CompanyDetailGroup {
        id: insiders
        itemData: dataRow.itemData
        anchors.top: basics.top
        anchors.left: income.right
        anchors.leftMargin: tm.rowH * 2

        groupName: "Shares owned by"
        headerModel: [qsTr("Insiders"), qsTr(""), qsTr("Institutions")]
        itemRoles:  ["sharesInsider", "insidersOwn", "sharesInst"]
        inputModes: {"insidersOwn": "%"}
        colEdit: {"insidersOwn": false}
        prevFocus: income.lastFocusItem
    }

    //row2
    CompanyDetailGroup {
        id: assets
        itemData: dataRow.itemData
        anchors.top: basics.bottom
        anchors.left: basics.left
        anchors.topMargin: 0
        groupName: "Assets"
        headerModel: [qsTr("Fixed"), qsTr("Fixed: PPE"), qsTr("Current"), qsTr("Current: Cash")]
        itemRoles:  ["assetsFixed", "assetsFixedPpe", "assetsCurr", "assetsCurrCash"]
        prevFocus: insiders.lastFocusItem
    }

    CompanyDetailGroup {
        id: equityAndLiab
        itemData: dataRow.itemData
        anchors.top: assets.top
        anchors.left: assets.right
        anchors.leftMargin: tm.rowH * 2
        groupName: "Equity & Liab"
        headerModel: [qsTr("Equity"), qsTr("N.C. liab."), qsTr("N.C. liab.: Intb."), qsTr("Current liab."), qsTr("Current liab: Intb.")]
        itemRoles:  ["equity", "liabLong", "liabLongInt", "liabCurr", "liabCurrInt"]
        prevFocus: assets.lastFocusItem
    }

    //row3
    CompanyDetailGroup {
        id: expenses
        itemData: dataRow.itemData
        anchors.top: assets.bottom
        anchors.left: assets.left
        anchors.topMargin: 0
        groupName: "Expenses"
        headerModel: [qsTr("Dividend"), qsTr("Remuneration"), qsTr("Interest payed"), qsTr("Debt maturity")]
        itemRoles:  ["dividend", "managRemun",  "interestPayed", "debtMaturity"]
        prevFocus: equityAndLiab.lastFocusItem
    }

    CompanyDetailGroup {
        id: leasing
        itemData: dataRow.itemData
        anchors.top: expenses.top
        anchors.left: equityAndLiab.left
        groupName: "Leasing"
        headerModel: [qsTr("This y."), qsTr("+1"), qsTr("+2-5"), qsTr("+5")]
        itemRoles:  ["leasingY", "leasingY1", "leasingY2Y5", "leasingY5Up"]
        prevFocus: expenses.lastFocusItem
    }

}
