import QtQuick 2.7

AListItem {
    id: financials
    signal select(int index)

    itemData: {"id": "",
               "cId": "",
               "year": "",
               "qId": "",
               "sales": "",
               "ebit": "" }
    property variant colW: [40, 80, 80, 80, 80, 80]
    property int wComp: 0
    property int rowH: 30
    height: rowH

    //property int currentCol : row
    Row {
        id: row
        anchors.fill: parent
        spacing: 10
        anchors.leftMargin: 10

        CompanyCellEditText {
            id: idText
            roleSelector: financials.focusRole
            role: "id"
            model: itemData
            width: colW[0] - wComp
            visible: false
            enabled: false
        }
        CompanyCellEditText {
            id: year
            roleSelector: financials.focusRole
            role: "year"
            model: itemData
            width: colW[1] - wComp
            enabled: financials.showEdit
            nextFocus: quarter
        }
        CompanyCellDropDown {
            id: quarter
            roleSelector: financials.focusRole
            role: "qId"
            model: itemData
            enabled: financials.showEdit
            comboModel: quartersModel
            width: colW[2] - wComp
            nextFocus: sales
        }

        CompanyCellEditText {
            id: sales
            roleSelector: financials.focusRole
            role: "sales"
            model: itemData
            width: colW[4] - wComp
            enabled: financials.showEdit
            nextFocus: ebit
        }
        CompanyCellEditText {
            id: ebit
            roleSelector: financials.focusRole
            role: "ebit"
            model: itemData
            width: colW[5] - wComp
            enabled: financials.showEdit
            nextFocus: year
        }
    }
    MouseArea {
        anchors.fill: parent
        enabled: !showEdit
        onClicked: {
            select(index);
        }
    }
}
