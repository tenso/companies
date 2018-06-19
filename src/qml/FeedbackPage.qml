import QtQuick 2.9
import QtQuick.Controls 2.2

APage {
    id: page
    Theme {id:tm}

    function refresh() {
        if (page.active) {
            financialsModel.filterColumn("qId", "");
            if (selectedData) {
                financialsModel.filterColumn("cId", "=" + selectedData.id);
                analysisModel.filterColumn("cId", "=" + selectedData.id);
                magicModel.filterColumn("cId", "=" + selectedData.id);
            }
            priceGraph.redraw();
            dataGraph.redraw();
        }
    }

    onActiveChanged: {
        refresh();
    }

    SelectedCompany {
        id: head
        selectedData: page.selectedData
        colW: page.colW

        onSelectionChanged: {
            refresh();
        }
    }

    PriceGraph {
        id: priceGraph
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: head.bottom
        height: (parent.height - head.height) / 2
    }

    DetailsGraph {
        id: dataGraph
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: priceGraph.bottom
        anchors.bottom: parent.bottom

        model: financialsModel
        categoryRole: "year"
        showOrder: ["sales", "ebit", "dividend"]
        setColors: {"sales": tm.graph2, "ebit": tm.graph1, "dividend": tm.graph3}

        filterRole: "qId"
        filterEqValue: 0
    }
}
