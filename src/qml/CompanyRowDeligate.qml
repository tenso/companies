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
            id: name
            width: colW[1] - wComp
            text: itemData ? itemData.name : ""
            enabled: companyRow.showEdit
            onUpdated: {
                itemData.name = text;
                logStatus("id=" + idText.text + " set name=" + text);
            }
            KeyNavigation.right: list
            KeyNavigation.tab: list
        }
        CompanyCellDropDown {
            id: list
            enabled: companyRow.showEdit
            comboModel: listsModel
            width: colW[2] - wComp
            text: itemData ? itemData.lId : ""
            onUpdated: {
                itemData.lId = id;
                logStatus("id=" + idText.text + " set lId=" + id);
            }
            KeyNavigation.right: type
            KeyNavigation.tab: type
        }
        CompanyCellDropDown {
            id: type
            enabled: companyRow.showEdit
            comboModel: typesModel
            width: colW[3] - wComp
            text: itemData ? itemData.tId : ""
            onUpdated: {
                itemData.tId = id;
                logStatus("id=" + idText.text + " set tId=" + id);
            }
            KeyNavigation.right: watch
            KeyNavigation.tab: watch
        }
        CompanyCellEditText {
            id: watch
            width: colW[4] - wComp
            text: itemData ? itemData.watch : ""
            enabled: companyRow.showEdit
            onUpdated: {
                itemData.watch = text;
                logStatus("id=" + idText.text + " set watch=" + text);
            }
            KeyNavigation.right: description
            KeyNavigation.tab: description
        }
        CompanyCellEditText {
            id: description
            width: colW[5] - wComp
            text: itemData ? itemData.description : ""
            enabled: companyRow.showEdit
            onUpdated: {
                itemData.description = text;
                logStatus("id=" + idText.text + " set desc=" + text);
            }
            KeyNavigation.right: name
            KeyNavigation.tab: name
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
