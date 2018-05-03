import QtQuick 2.7
import QtQuick.Controls 2.2

Page {
    id: page
    property int rowH: 0
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
        height: page.rowH * 2 + 10
        colW: page.colW
        model: [qsTr("Id"), qsTr("Name"), qsTr("List"), qsTr("Type"), qsTr("Watch"), qsTr("Description")]

        onFilterChange: {
            companiesModel.filterColumn(index, filter);
        }
    }

    AList {
        id: view
        model: companiesModel
        anchors.fill: parent
        anchors.topMargin: listHead.height

        delegate: CompanyRowDeligate {
            itemData: model
            width: page.width
            height: page.rowH
            colW: page.colW

            onSelect: {
                view.currentIndex = index;
                view.forceActiveFocus();
            }
        }
    }
}
