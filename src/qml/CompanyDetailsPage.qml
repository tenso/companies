import QtQuick 2.9
import QtQuick.Controls 2.2

Page {
    id: page
    Theme {id:tm}
    property alias selectedData: currentCompany.itemData
    property alias rowCount: view.count
    property variant colW: []
    property bool active: false

    DataMenu {
        id: controls
        x: pageMenuX
        y: pageMenuY
        active: page.active
        model: financialsModel
        addId: currentCompany.itemData ? currentCompany.itemData.id : -1;
        addIdCol: 1
        enabled: currentCompany.itemData ? true : false
        view: view
    }

    Rectangle {
        id: head
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: tm.rowH * 2 + tm.margin
        color: tm.headBg

        CompanyHeaderDeligate {
            id: listHead
            width: page.width
            height: tm.rowH
            colW: page.colW
            x: tm.margin
            itemData: [qsTr("Id"), qsTr("Name"), qsTr("List"), qsTr("Type"), qsTr("Watch"), qsTr("Description")]
        }

        AListRow {
            id: currentCompany
            roles:  ["id", "name", "lId", "tId", "watch", "description"]
            comboModels: { "lId": listsModel, "tId": typesModel }
            itemData: overview.currentItemData
            anchors.left: parent.left
            anchors.leftMargin: tm.margin
            anchors.right: parent.right
            anchors.top: listHead.bottom
            showEdit: true
            colW: page.colW
            onItemDataChanged: {
                if (itemData) {
                    financialsModel.filterColumn(1, "=" + itemData.id);
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
        height: tm.rowH * 10 + view.spacing
        color: tm.headBg

        AList {
            id: view
            model: financialsModel
            anchors.fill: parent
            snapMode: ListView.SnapToItem
            //spacing: tm.margin
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
