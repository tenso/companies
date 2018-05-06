import QtQuick 2.9

AListItem {
    id: financials
    signal select(int index)

    itemData: {"id": "",
               "cId": "",
               "year": "",
               "qId": "",
               "sales": "",
               "ebit": "" }
    property int colW: 80
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
            width: colW
            visible: false
            enabled: false
        }
        CompanyCellEditText {
            id: year
            roleSelector: financials.focusRole
            role: "year"
            model: itemData
            width: colW
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
            width: colW
            nextFocus: shares
        }
        CompanyCellEditText {
            id: shares
            roleSelector: financials.focusRole
            role: "shares"
            model: itemData
            width: colW
            enabled: financials.showEdit
            nextFocus: sales
        }
        CompanyCellEditText {
            id: sales
            roleSelector: financials.focusRole
            role: "sales"
            model: itemData
            width: colW
            enabled: financials.showEdit
            nextFocus: ebit
        }
        CompanyCellEditText {
            id: ebit
            roleSelector: financials.focusRole
            role: "ebit"
            model: itemData
            width: colW
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
