import QtQuick 2.9
import QtQuick.Controls 2.2

Page {
    id: page
    Theme {id:tm}
    property variant colW: []
    property alias count: view.count
    property variant currentItemData: view.currentItem ? view.currentItem.itemData : null

    function savePos() {
        view.savePos();
    }
    function resetPos() {
        view.resetPos();
    }

    Rectangle {
        id: head
        color: tm.headBg
        width: page.width
        height: childrenRect.height

        CompanyHeaderDeligate {
            id: listHead
            width: page.width
            height: tm.rowH
            colW: page.colW
            x: tm.margin
            itemData: [qsTr("Id"), qsTr("Name"), qsTr("List"), qsTr("Type"), qsTr("Watch"), qsTr("Description")]
        }
        CompanyFilter {
            id: filter
            anchors.top: listHead.bottom
            anchors.left: parent.left
            anchors.leftMargin: tm.margin
            colW: page.colW
            width: page.width
            height: tm.rowH + 10
        }
    }
    AList {
        id: view
        model: companiesModel
        anchors.left: parent.left
        anchors.leftMargin: tm.margin
        anchors.right: parent.right
        anchors.top: head.bottom
        anchors.bottom: parent.bottom

        delegate: AListRow {
            itemData: model
            roles:  ["id", "name", "lId", "tId", "watch", "description"]
            comboModels: { "lId": listsModel, "tId": typesModel }
            width: page.width
            height: tm.rowH
            colW: page.colW

            onSelect: {
                view.currentIndex = index;
                view.forceActiveFocus();
            }
        }
    }
}
