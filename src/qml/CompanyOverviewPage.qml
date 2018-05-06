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

    CompanyHeaderDeligate {
        id: listHead
        width: page.width
        height: tm.rowH * 2 + 10
        colW: page.colW
        model: [qsTr("Id"), qsTr("Name"), qsTr("List"), qsTr("Type"), qsTr("Watch"), qsTr("Description")]
        filterEnabled: true
        onFilterChange: {
            companiesModel.filterColumn(index, filter);
        }
    }

    AList {
        id: view
        model: companiesModel
        anchors.fill: parent
        anchors.topMargin: listHead.height

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
