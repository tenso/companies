import QtQuick 2.7

Rectangle {
    id: financials
    color: "transparent"
    signal select(int index)

    property variant itemData: {"id": "",
                                "cId": "",
                                "year": "",
                                "qId": "",
                                "sales": "",
                                "ebit": "" }
    property variant colW: [40, 80, 80, 80, 80, 80]
    property bool showEdit: false
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
            width: colW[0] - wComp
            id: idText
            visible: false
            text: itemData ? itemData.id : ""
            enabled: false
        }
        CompanyCellEditText {
            id: year
            width: colW[1] - wComp
            text: itemData ? itemData.year : ""
            enabled: financials.showEdit
            onUpdated: {
                itemData.year = text;
                logStatus("id=" + idText.text + " set year=" + text);
            }
            KeyNavigation.right: quarter
            KeyNavigation.tab: quarter
        }
        CompanyCellDropDown {
            id: quarter
            enabled: financials.showEdit
            comboModel: quartersModel
            width: colW[2] - wComp
            text: itemData ? itemData.qId : ""
            onUpdated: {
                itemData.qId = id;
                logStatus("id=" + idText.text + " set qId=" + id);
            }
            KeyNavigation.right: sales
            KeyNavigation.tab: sales
        }

        CompanyCellEditText {
            id: sales
            width: colW[4] - wComp
            text: itemData ? itemData.sales : ""
            enabled: financials.showEdit
            onUpdated: {
                itemData.sales = text;
                logStatus("id=" + idText.text + " set sales=" + text);
            }
            KeyNavigation.right: ebit
            KeyNavigation.tab: ebit
        }
        CompanyCellEditText {
            id: ebit
            width: colW[5] - wComp
            text: itemData ? itemData.ebit : ""
            enabled: financials.showEdit
            onUpdated: {
                itemData.ebit = text;
                logStatus("id=" + idText.text + " set ebit=" + text);
            }
            KeyNavigation.right: year
            KeyNavigation.tab: year
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
