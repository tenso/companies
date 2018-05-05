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

    Row {
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
            width: colW[1] - wComp
            text: itemData ? itemData.year : ""
            enabled: financials.showEdit
            onUpdated: {
                itemData.year = text;
                logStatus("id=" + idText.text + " set year=" + text);
            }
        }
        CompanyCellDropDown {
            enabled: financials.showEdit
            comboModel: quartersModel
            width: colW[2] - wComp
            text: itemData ? itemData.qId : ""
            onUpdated: {
                itemData.qId = id;
                logStatus("id=" + idText.text + " set qId=" + id);
            }
        }

        CompanyCellEditText {
            width: colW[4] - wComp
            text: itemData ? itemData.sales : ""
            enabled: financials.showEdit
            onUpdated: {
                itemData.sales = text;
                logStatus("id=" + idText.text + " set sales=" + text);
            }
        }
        CompanyCellEditText {
            width: colW[5] - wComp
            text: itemData ? itemData.ebit : ""
            enabled: financials.showEdit
            onUpdated: {
                itemData.ebit = text;
                logStatus("id=" + idText.text + " set ebit=" + text);
            }
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
