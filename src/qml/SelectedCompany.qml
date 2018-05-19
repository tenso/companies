import QtQuick 2.9

Rectangle {
    id: root
    height: tm.rowH * 2 + tm.margin
    width: parent.width
    color: tm.headBg

    property variant colW
    property alias selectedData: currentCompany.itemData

    signal selectionChanged()

    CompanyHeaderDeligate {
        id: listHead
        width: root.width
        height: tm.rowH
        colW: root.colW
        x: tm.margin
        itemData: [qsTr("Id"), qsTr("Name"), qsTr("List"), qsTr("Type"), qsTr("Watch"), qsTr("Description")]
    }

    AListRow {
        id: currentCompany
        roles:  ["id", "name", "lId", "tId", "watch", "description"]
        comboModels: { "lId": listsModel, "tId": typesModel }
        anchors.left: parent.left
        anchors.leftMargin: tm.margin
        anchors.right: parent.right
        anchors.top: listHead.bottom
        showEdit: true
        colW: root.colW
        onItemDataChanged: selectionChanged()
    }
}
