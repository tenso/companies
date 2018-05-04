import QtQuick 2.7
import QtQuick.Controls 2.2

Page {
    id: page
    property alias selectedData: currentCompany.itemData
    property int rowH: 0
    property variant colW: []

    CompanyRowDeligate {
        id: currentCompany
        itemData: overview.currentItemData
        anchors.top: parent.top
        anchors.margins: rowH
        anchors.left: parent.left
        anchors.right: parent.right
        showEdit: true
        height: page.rowH
        colW: page.colW
    }
    Rectangle {
        width: 800
        id: financials
        anchors.left: parent.left
        anchors.top: currentCompany.bottom
        anchors.bottom: parent.bottom
        anchors.margins: rowH
        color: tm.menuBg

        AList {
            id: view
            model: financialsModel
            anchors.fill: financials
            anchors.bottomMargin: newButton.height
            delegate: FinancialRowDeligate {
                itemData: model
                width: view.width
                rowH: page.rowH

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
                financialsModel.newRow();
            }
        }
    }
}
