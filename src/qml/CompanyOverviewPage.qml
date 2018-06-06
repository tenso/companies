import QtQuick 2.9
import QtQuick.Controls 2.2

APage {
    id: page
    Theme {id:tm}
    rowCount: view.count
    selectedData: view.currentItem ? view.currentItem.itemData : null

    readonly property int sortNone: 0
    readonly property int sortMagicDcf: 1
    readonly property int sortDcfMagic: 2
    property int sortOrder: sortNone

    function savePos() {
        view.savePos();
    }
    function resetPos() {
        view.resetPos();
    }

    function reSort() {
        companiesModel.clearSort();
        if (sortOrder == sortDcfMagic) {
            companiesModel.setSort("aId", Qt.DescendingOrder);
            companiesModel.setSort("maId", Qt.DescendingOrder);
        }
        else if (sortOrder == sortMagicDcf) {
            companiesModel.setSort("maId", Qt.DescendingOrder);
            companiesModel.setSort("aId", Qt.DescendingOrder);
        }
        companiesModel.applySort();
    }

    onSortOrderChanged: {
        reSort();
    }

    onActiveChanged: {
        reSort();
    }

    DataMenu {
        id: dataMenu
        model: companiesModel
        view: view
        x: pageMenuX
        y: pageMenuY
        active: page.active

        onWillDelete: {
            //FIXME: move all db-logic to c++ and add rest (tags etc)!
            financialsModel.clearFilters();
            if (!financialsModel.delAllRows("cId", id)) {
                logError("del financials for " + id + " failed");
            }
            if (!analysisEngine.delAllAnalysis(id)) {
                logError("del analysises for " + id + " failed");
            }
        }
    }

    AButton {
        id: sort
        height: tm.rowH
        width: tm.colW
        text: qsTr("Sort")
        onClicked: sortMenu.open()
        font: tm.font
        anchors.leftMargin: tm.margin
        anchors.left: dataMenu.right
        anchors.top: dataMenu.top
        Menu {
            id: sortMenu
            MenuItem {
                font: tm.font
                text: qsTr("None")
                onTriggered: sortOrder = sortNone
            }
            MenuItem {
                font: tm.font
                text: qsTr("Dcf->Magic")
                onTriggered: sortOrder = sortDcfMagic
            }
            MenuItem {
                font: tm.font
                text: qsTr("Magic->Dcf")
                onTriggered: sortOrder = sortMagicDcf
            }
        }
    }

    Rectangle {
        id: head
        color: tm.headBg
        width: page.width
        height: tm.rowH * 2 + tm.margin

        CompanyHeaderDeligate {
            id: listHead
            width: page.width
            height: tm.rowH
            colW: page.colW
            x: tm.margin
            itemData: [qsTr("Id"), qsTr("Name"), qsTr("List"), qsTr("Type"), qsTr("Watch"),
                qsTr("Description"), qsTr("Rebate"), qsTr("MScore")]
        }
        CompanyFilter {
            id: filter
            anchors.top: listHead.bottom
            anchors.left: parent.left
            anchors.leftMargin: tm.margin
            colW: page.colW
            width: page.width
            height: tm.rowH
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

        delegate: CompanyRow {
            itemData: model
            width: page.width
            height: tm.rowH
            colW: page.colW

            //FIXME: move to AItem?
            onSelect: {
                view.currentIndex = index;
                view.positionViewAtIndex(view.currentIndex, ListView.Contain)
            }
        }
    }
}
