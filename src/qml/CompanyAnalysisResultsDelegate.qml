import QtQuick 2.9

AItem {
    Theme {id:tm}

    id: dataRow
    height: tm.rowH

    CompanyDetailGroup {
        id: m1
        itemData: dataRow.itemData
        groupName: ""
        showEdit: false
        itemRoles:  ["step", "sales", "ebit", "ebitMargin",  "salesGrowth",
            "reinvestments", "investedCapital", "fcf", "dcf"]

        inputModes: {"ebitMargin": "%", "salesGrowth": "%"}
    }
}
