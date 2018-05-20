import QtQuick 2.9
import QtQuick.Controls 2.2

APage {
    id: page
    Theme {id:tm}
    rowCount: view.count
    selectedData: view.currentItem ? view.currentItem.itemData : null

    function savePos() {
        view.savePos();
    }
    function resetPos() {
        view.resetPos();
    }

    DataMenu {
        id: controls
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

            onSelect: {
                view.currentIndex = index;
                //NOTE: cant force focus here; will steal filter focus.
            }
        }
    }
}
