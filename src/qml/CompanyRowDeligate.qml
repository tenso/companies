import QtQuick 2.7

Rectangle {
    id: companyRow
    color: "transparent"
    signal select(int index)

    property variant itemData: {"id": "",
                                "name": "",
                                "description": "",
                                "lId": "",
                                "tId": "",
                                "watch": "" }
    property variant colW: [0, 0, 0, 0, 0, 0]
    property bool showEdit: false
    property int wComp: 20
    Row {
        anchors.fill: parent
        spacing: 30
        anchors.leftMargin: 10

        CompanyCellEditText {
            width: colW[0] - wComp
            id: idText
            text: itemData ? itemData.id : ""
            enabled: false
        }
        CompanyCellEditText {
            width: colW[1] - wComp
            text: itemData ? itemData.name : ""
            enabled: companyRow.showEdit
            onUpdated: {
                itemData.name = text;
                addStatus(qsTr("id=" + idText.text + " set name=" + text));
            }
        }
        CompanyCellDropDown {
            enabled: companyRow.showEdit
            comboModel: listsModel
            width: colW[2] - wComp
            text: itemData ? itemData.lId : ""
            onUpdated: {
                itemData.lId = id;
                addStatus(qsTr("id=" + idText.text + " set lId=" + id));
            }
        }
        CompanyCellDropDown {
            id: typeSelect
            enabled: companyRow.showEdit
            comboModel: typesModel
            width: colW[3] - wComp
            text: itemData ? itemData.tId : ""
            onUpdated: {
                itemData.tId = id;
                addStatus(qsTr("id=" + idText.text + " set tId=" + id));
            }
        }
        CompanyCellEditText {
            width: colW[4] - wComp
            text: itemData ? itemData.watch : ""
            enabled: companyRow.showEdit
            onUpdated: {
                itemData.watch = text;
                addStatus(qsTr("id=" + idText.text + " set watch=" + text));
            }
        }
        CompanyCellEditText {
            width: colW[5] - wComp
            text: itemData ? itemData.description : ""
            enabled: companyRow.showEdit
            onUpdated: {
                itemData.description = text;
                addStatus(qsTr("id=" + idText.text + " set desc=" + text));
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
