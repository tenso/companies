import QtQuick 2.9

AItem {
    Theme {id:tm}

    id: dataRow
    width: tm.wideW
    height: tm.rowH * 10

    Rectangle {
        id: bg
        anchors.fill: parent
        color: "transparent"

        Text {
            width: tm.wideW
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: tm.margin * 2
            anchors.topMargin: tm.margin
            text: itemData ? "(" + itemData.id + ")" : ""
        }
    }


    CompanyDetailGroup {
        id: m1
        anchors.left: parent.left
        anchors.leftMargin: tm.rowH * 3 + tm.margin
        itemData: dataRow.itemData
        groupName: ""
        headerModel: [qsTr("Tax"), qsTr("Market premium"), qsTr("Riskfree"), qsTr("Risky"), qsTr("Beta"),
            qsTr("Sales Mode"), qsTr("Margin mode")]
        itemRoles:  ["tax", "marketPremium", "riskFreeRate", "riskyCompany", "beta",
            "salesGrowthMode", "ebitMarginMode"]
        itemCombos: {"salesGrowthMode": modesModel, "ebitMarginMode" : modesModel};
        inputModes: {"tax": "%", "marketPremium": "%", "riskFreeRate": "%"}
        itemW: tm.wideW
    }
    CompanyDetailGroup {
        id: m2
        itemData: dataRow.itemData
        anchors.top: m1.bottom
        anchors.left: m1.left

        groupName: ""
        headerModel: [qsTr("Growth yrs."), qsTr("Sales"), qsTr("Margin"), qsTr("Terminal margin"),
            qsTr("Growth"), qsTr("Terminal growth"), qsTr("Sales/Cap.empl"), qsTr("WACC")]
        itemRoles:  ["growthYears", "sales", "ebitMargin",  "terminalEbitMargin",
            "salesGrowth", "terminalGrowth", "salesPerCapital", "wacc"]
        itemW: tm.wideW
        inputModes: {"ebitMargin": "%", "terminalEbitMargin": "%", "salesGrowth": "%", "terminalGrowth": "%", "wacc": "%"}
    }
    CompanyDetailGroup {
        id: m3
        itemData: dataRow.itemData
        anchors.top: m2.bottom
        anchors.left: m1.left
        showEdit: false
        groupName: ""
        headerModel: [qsTr("Growth value"), qsTr("Terminal value"), qsTr("Total value")]
        itemRoles:  ["growthValueDiscounted", "terminalValueDiscounted", "totalValue"]
        itemW: tm.wideW
    }

    CompanyHeaderDeligate {
        id: resultHeader
        anchors.left: m1.left
        anchors.top:  m3.bottom
        singleW: tm.colW
        font: tm.font
        maximumLineCount: 2
        height: tm.rowH * 2
        titleH: height
        color: "transparent"
        textColor: tm.textFg
        itemData: [qsTr("Year"), qsTr("Sales"), qsTr("Ebit"), qsTr("Ebit margin"),
            qsTr("Sales growth"), qsTr("Reinvestments"), qsTr("Invested capital"), qsTr("FCF"), qsTr("DCF")]
    }

    Rectangle {
        id: analysisResults
        anchors.left: m1.left
        anchors.right: parent.right
        anchors.top: resultHeader.bottom
        anchors.bottom: parent.bottom
        color: "transparent"

        AList {
            id: view
            model: analysisResultsModel
            anchors.fill: parent
            snapMode: ListView.SnapToItem
            delegate: AItem {
                id: resultRow
                itemData: model
                height: delegateLoader.active ? tm.rowH : 0
                width: view.width
                visible: height > 0

                Loader {
                    id: delegateLoader
                    anchors.fill: parent
                    active: itemData.aId === dataRow.itemData.id
                    sourceComponent: delegate
                }
                Component {
                    id: delegate
                    CompanyAnalysisResultsDelegate {
                        itemData: resultRow.itemData
                        onSelect: {
                            view.currentIndex = index;
                        }
                    }
                }
            }
        }
    }
}

