import QtQuick 2.9
import QtQuick.Controls 2.2

AItem {
    Theme {id:tm}

    property variant buttonGroup
    property int myIndex: 0
    property alias checked: checkButton.checked
    id: root
    width: tm.wideW
    height: tm.rowH * 22 + separator.height

    signal setAnalysis(int id);

    Rectangle {
        id: bg
        anchors.fill: parent
        color: "transparent"

        Text {
            id: idText
            width: tm.wideW
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: tm.margin * 2
            anchors.topMargin: tm.margin
            text: itemData ? "(" + itemData.id + ")" : ""
        }
        ARadioButton {
            id: checkButton
            anchors.left: idText.left
            anchors.top: idText.bottom
            anchors.topMargin: tm.margin
            ButtonGroup.group: buttonGroup
            onCheckedChanged: {
                setAnalysis(root.itemData.id)
            }
        }
    }


    CompanyDetailGroup {
        id: m1
        anchors.left: parent.left
        anchors.leftMargin: tm.rowH * 3 + tm.margin
        itemData: root.itemData
        groupName: ""
        headerModel: [qsTr("Tax"), qsTr("Market premium"), qsTr("Riskfree"), qsTr("Risky"), qsTr("Beta"),
            qsTr("Sales Mode"), qsTr("Margin mode"), qsTr("WACC year")]
        itemRoles:  ["tax", "marketPremium", "riskFreeRate", "riskyCompany", "beta",
            "salesGrowthMode", "ebitMarginMode", "financialsMode"]
        itemCombos: {"salesGrowthMode": modesModel, "ebitMarginMode" : modesModel,
                     "financialsMode": calcModesModel, "riskyCompany": yesnoModel };
        inputModes: {"tax": "%", "marketPremium": "%", "riskFreeRate": "%"}
        itemW: tm.wideW
        prevFocus: m3.lastFocusItem
    }

    CompanyDetailGroup {
        id: m2
        itemData: root.itemData
        anchors.top: m1.bottom
        anchors.left: m1.left

        groupName: ""
        headerModel: [qsTr("Growth yrs."), qsTr("Sales"), qsTr("Margin"), qsTr("Terminal margin"),
            qsTr("Growth"), qsTr("Terminal growth"), qsTr("Sales/Cap.empl")]
        itemRoles:  ["growthYears", "sales", "ebitMargin",  "terminalEbitMargin",
            "salesGrowth", "terminalGrowth", "salesPerCapital"]
        itemW: tm.wideW
        inputModes: {"ebitMargin": "%", "terminalEbitMargin": "%", "salesGrowth": "%", "terminalGrowth": "%", "wacc": "%"}
        prevFocus: m1.lastFocusItem
    }

    CompanyDetailGroup {
        id: m3
        itemData: root.itemData
        anchors.top: m2.bottom
        anchors.left: m2.left

        groupName: ""
        headerModel: [qsTr("Shares"), qsTr("Share price"), qsTr("Year"), qsTr("Quarter")]
        itemRoles:  ["shares", "sharePrice", "year", "qId"]
        itemCombos: {"qId": quartersModel}
        itemW: tm.wideW
        prevFocus: m2.lastFocusItem
    }

    CompanyDetailGroup {
        id: m4
        itemData: root.itemData
        anchors.top: m3.bottom
        anchors.left: m3.left
        showEdit: false
        groupName: ""
        headerModel: [qsTr("WACC"), qsTr("Growth value"), qsTr("Terminal value"), qsTr("Total value"), qsTr("Value/share"), qsTr("Rebate")]
        itemRoles:  ["wacc", "growthValueDiscounted", "terminalValueDiscounted", "totalValue", "shareValue", "rebate"]
        inputModes: {"wacc": "%", "rebate": "%"}
        colorModes: {
            "rebate": { "limits": [-0.1, 0.1], "colors": [tm.fail, tm.warn, tm.ok] }
        }
        fontColors: {
            "rebate": tm.inActive
        }
        itemW: tm.wideW
    }

    /****************/
    /* Calculations */
    /****************/

    CompanyHeaderDeligate {
        id: resultHeader
        anchors.left: m4.left
        anchors.top:  m4.bottom
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
        width: resultHeader.width
        anchors.top: resultHeader.bottom
        anchors.bottom: separator.top
        anchors.bottomMargin: tm.rowH
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
                    active: itemData.aId === root.itemData.id
                    sourceComponent: delegate
                }
                Component {
                    id: delegate
                    CompanyAnalysisResultsDelegate {
                        itemData: resultRow.itemData
                        onSelect: {
                            root.select(root.myIndex);
                        }
                    }
                }
            }
        }
    }
    Rectangle {
        id: separator
        color: tm.headBg
        width: parent.width
        height: 1
        anchors.bottom: parent.bottom
    }
}

