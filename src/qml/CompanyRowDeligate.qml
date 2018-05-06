import QtQuick 2.9

AListItem {
    id: companyRow
    signal select(int index)

    itemData: {"id": "",
               "name": "",
               "description": "",
               "lId": "",
               "tId": "",
               "watch": "" }

    property variant colW: [0, 0, 0, 0, 0, 0]
    property int wComp: 20

    Row {
        id: row
        anchors.fill: parent
        spacing: 30
        anchors.leftMargin: 10

        CompanyCellEditText {
            id: idText
            roleSelector: companyRow.focusRole
            role: "id"
            model: itemData
            width: colW[0] - wComp
            enabled: false
        }
        CompanyCellEditText {
            id: name
            roleSelector: companyRow.focusRole
            role: "name"
            model: itemData
            width: colW[1] - wComp
            enabled: companyRow.showEdit
            nextFocus: list
        }
        CompanyCellDropDown {
            id: list
            roleSelector: companyRow.focusRole
            role: "lId"
            model: itemData
            enabled: companyRow.showEdit
            comboModel: listsModel
            width: colW[2] - wComp
            nextFocus: type
        }
        CompanyCellDropDown {
            roleSelector: companyRow.focusRole
            role: "tId"
            model: itemData
            id: type
            enabled: companyRow.showEdit
            comboModel: typesModel
            width: colW[3] - wComp
            nextFocus: watch
        }
        CompanyCellEditText {
            id: watch
            roleSelector: companyRow.focusRole
            role: "watch"
            model: itemData
            width: colW[4] - wComp
            enabled: companyRow.showEdit
            nextFocus: description
        }
        CompanyCellEditText {
            id: description
            roleSelector: companyRow.focusRole
            role: "description"
            model: itemData
            width: colW[5] - wComp
            enabled: companyRow.showEdit
            nextFocus: name
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
