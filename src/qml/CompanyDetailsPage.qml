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
        showEdit: true
        width: parent.width
        height: page.rowH
        colW: page.colW
    }
    Rectangle {

    }
}
