import QtQuick 2.9
import QtQuick.Controls 2.2

APage {
    id: page
    Theme {id:tm}
    rowCount: view.count

    DataMenu {
        id: controls
        x: pageMenuX
        y: pageMenuY
        active: page.active
        model: financialsModel
        addId: page.selectedData ? page.selectedData.id : -1;
        addIdCol: 1
        enabled: page.selectedData ? true : false
        view: view
    }

    SelectedCompany {
        id: head
        selectedData: page.selectedData
        colW: page.colW

        onSelectionChanged: {
            if (selectedData) {
                financialsModel.filterColumn(1, "=" + selectedData.id);
            }
            graph.redraw();
        }
    }

    Rectangle {
        id: financials
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: head.bottom
        height: tm.rowH * 10 + view.spacing
        color: tm.headBg

        AList {
            id: view
            model: financialsModel
            anchors.fill: parent
            snapMode: ListView.SnapToItem
            delegate: CompanyDetailsDeligate {
                width: view.width
                itemData: model

                onSelect: {
                    view.currentIndex = index;
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
        filterEqValue: "FY"
    }
}
