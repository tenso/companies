import QtQuick 2.7
import QtQuick.Controls 2.2

Page {
    id: page
    Theme {id:tm}
    property alias selectedData: currentCompany.itemData
    property alias rowCount: view.count
    property variant colW: []

    CompanyRowDeligate {
        id: currentCompany
        itemData: overview.currentItemData
        anchors.top: parent.top
        anchors.margins: tm.rowH
        anchors.left: parent.left
        anchors.right: parent.right
        showEdit: true
        height: tm.rowH
        colW: page.colW
        onItemDataChanged: {
            if (itemData) {
                financialsModel.filterColumn(1, "=" + itemData.id);
            }
        }
    }
    Rectangle {
        width: 800
        id: financials
        anchors.left: parent.left
        anchors.top: currentCompany.bottom
        anchors.bottom: parent.bottom
        anchors.margins: tm.rowH
        color: tm.menuBg

        AList {
            id: view
            model: financialsModel
            anchors.fill: financials
            anchors.bottomMargin: newButton.height
            delegate: FinancialRowDeligate {
                itemData: model
                width: view.width
                rowH: tm.rowH

                onSelect: {
                    view.currentIndex = index;
                    view.forceActiveFocus();
                }
            }
        }
        AButton {
            id: newButton
            anchors.top: view.bottom
            text: qsTr("New entry")
            onPressed: {
                var cId = currentCompany.itemData.id;
                var row = financialsModel.newRow(1, cId);
                if (row === -1) {
                    logError("new row failed " + cId);
                }
                else {
                    logStatus("added row " + row + " for " + cId);
                }
            }
        }
        AButton {
            id: delButton
            anchors.left: newButton.right
            anchors.top: newButton.top
            anchors.leftMargin: tm.rowH
            text: qsTr("Remove entry")
            onPressed: {
                var cId = currentCompany.itemData.id;
                var row = view.currentIndex;
                if (!financialsModel.delRow(row)) {
                    logError("del row failed " + row + " for " + cId);
                }
                else {
                    logStatus("removed row " + row + " for " + cId);
                }
            }
        }
    }
}
