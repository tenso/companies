import QtQuick 2.9
import QtQuick.Controls 2.2

APage {
    id: page
    Theme {id:tm}
    rowCount: view.count

    function doRefresh() {
        if (page.active) {
            financialsModel.filterColumn("qId", "");
            if (selectedData) {
                financialsModel.filterColumn("cId", "=" + selectedData.id);
            }
        }
    }

    onActiveChanged: {
        refresh();
    }

    function savePos() {
        view.savePos();
    }
    function resetPos() {
        view.resetPos();
    }

    DataMenu {
        id: controls
        x: pageMenuX
        y: pageMenuY
        active: page.active
        model: financialsModel
        addId: page.selectedData ? page.selectedData.id : -1;
        addIdRole: "cId"
        enabled: page.selectedData ? true : false
        view: view
    }

    SelectedCompany {
        id: head
        selectedData: page.selectedData
        colW: page.colW

        onSelectionChanged: {
            refresh();
        }
    }

    Rectangle {
        id: financials
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: head.bottom
        anchors.bottom: parent.bottom
        color: tm.inActive

        AList {
            id: view
            model: financialsModel
            anchors.fill: parent
            snapMode: ListView.SnapToItem
            delegate: CompanyDetailsDeligate {
                width: view.width
                itemData: model

                //FIXME: move to AItem?
                onSelect: {
                    view.currentIndex = index;
                    view.positionViewAtIndex(view.currentIndex, ListView.Contain)
                }
            }
        }
    }
}
