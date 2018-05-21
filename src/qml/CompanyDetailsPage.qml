import QtQuick 2.9
import QtQuick.Controls 2.2

APage {
    id: page
    Theme {id:tm}
    rowCount: view.count

    onActiveChanged: {
        if (active) {
            financialsModel.filterColumn("qId", "");
            if (selectedData) {
                financialsModel.filterColumn("cId", "=" + selectedData.id);
            }
            graph.redraw();
        }
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
            if (page.active) {
                if (selectedData) {
                    financialsModel.filterColumn("cId", "=" + selectedData.id);
                }
                graph.redraw();
            }
        }
    }

    Rectangle {
        id: financials
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: head.bottom
        height: (tm.rowH * 10 + view.spacing) * 2
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
    DetailsGraph {
        id: graph
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: financials.bottom
        anchors.bottom: parent.bottom

        model: financialsModel
        categoryRole: "year"
        showOrder: ["sales", "ebit", "dividend"]
        setColors: {"sales": tm.graph2, "ebit": tm.graph1, "dividend": tm.graph3}

        filterRole: "qId"
        filterEqValue: 1
    }
}
