import QtQuick 2.9

AItem {
    id: dataRow
    property alias headerModel: header.itemData
    property alias itemRoles: items.roles
    property alias itemCombos: items.comboModels
    property alias inputModes: items.inputModes
    property alias groupName:  groupNameItem.text
    property alias itemW: items.singleW
    focusRole: parent.focusRole
    itemData: parent.itemData
    showEdit: parent.showEdit

    onSelect: {
        parent.select(index);
    }

    height: tm.rowH * 3
    width: row.width
    Row {
        id: row
        height: parent.height
        spacing: tm.margin
        Rectangle {
            id: group
            width: groupName !== "" ? itemW : 0
            height: parent.height
            color: "transparent"

            Text {
                id: groupNameItem
                height: parent.height
                width: parent.width
                font: tm.headFont
                color: tm.textFg
                maximumLineCount: 2
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignBottom
                bottomPadding: 5
                wrapMode: Text.Wrap
            }
        }

        Column {
            CompanyHeaderDeligate {
                id: header
                singleW: itemW
                font: tm.font
                maximumLineCount: 2
                height: tm.rowH * 2
                titleH: height
                color: "transparent"
                textColor: tm.textFg
            }
            AListRow {
                id: items
                itemData: dataRow.itemData
                onSelect: dataRow.select(index);
                focus: true
                showEdit: dataRow.showEdit
                focusRole: dataRow.focusRole
                singleW: tm.colW
            }
        }
    }
}
