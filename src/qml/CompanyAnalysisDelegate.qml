import QtQuick 2.9

AItem {
    Theme {id:tm}

    id: dataRow
    height: tm.rowH * 10

    Rectangle {
        id: bg
        anchors.fill: parent
        color: tm.inActive

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
        id: m1
        itemData: dataRow.itemData
        groupName: ""
        headerModel: [qsTr("Tax"), qsTr("Market premium"), qsTr("Riskfree"), qsTr("Growth yrs."),
            qsTr("Terminal growth"), qsTr("Sales Mode"), qsTr("Margin mode")]
        itemRoles:  ["tax", "marketPremium", "riskFreeRate", "growthYears",  "terminalGrowth", "salesGrowthMode", "ebitMarginMode"]
    }
    CompanyDetailGroup {
        id: m2
        itemData: dataRow.itemData
        anchors.top: m1.bottom
        anchors.left: m1.left

        groupName: ""
        headerModel: [qsTr("Beta"), qsTr("Risky"), qsTr("Sales"), qsTr("Margin"), qsTr("Terminal margin"),
            qsTr("Growth"), qsTr("Sales/Cap.empl"), qsTr("WACC")]
        itemRoles:  ["beta", "riskyCompany", "sales", "ebitMargin",  "terminalEbitMargin", "salesGrowth", "salesPerCapital", "wacc"]
    }
    CompanyDetailGroup {
        id: m3
        itemData: dataRow.itemData
        anchors.top: m2.bottom
        anchors.left: m1.left

        groupName: ""
        headerModel: [qsTr("Growth value"), qsTr("Terminal value"), qsTr("Total value")]
        itemRoles:  ["growthValueDiscounted", "terminalValueDiscounted", "totalValue"]
    }
}
