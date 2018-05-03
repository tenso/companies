import QtQuick 2.7
import QtQuick.Controls 2.2

Page {
    id: page
    property int rowH: 0
    property variant colW: []
    property alias count: view.count
    property variant currentItemData: view.currentItem ? view.currentItem.itemData : null
    property int _selectedRow: 0
    property int _selectedY: 0
    function savePos() {
        _selectedRow = view.currentIndex;
        _selectedY = view.contentY;
        view.currentIndex = -1;
    }
    function resetPos() {
        view.currentIndex = _selectedRow;
        view.contentY = _selectedY;
    }

    CompanyHeaderDeligate {
        id: listHead
        width: page.width
        height: page.rowH * 2 + 10
        colW: page.colW
        model: [qsTr("Id"), qsTr("Name"), qsTr("List"), qsTr("Type"), qsTr("Watch"), qsTr("Description")]

        onFilterChange: {
            companiesModel.filterColumn(index, filter);
        }
    }

    ListView {
        id: view
        clip: true
        model: companiesModel
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: listHead.bottom
        anchors.bottom: parent.bottom
        focus: true
        boundsBehavior: Flickable.StopAtBounds
        keyNavigationEnabled: true

        property var lastItem: currentItem

        onCurrentItemChanged: {
            if (lastItem) {
                lastItem.showEdit = false;
            }
            if (currentItem) {
                currentItem.showEdit = true;
            }
        }

        delegate: CompanyRowDeligate {
            itemData: model
            width: page.width
            height: page.rowH
            colW: page.colW

            onSelect: {
                view.currentIndex = index;
                view.forceActiveFocus();
            }
        }

        highlightFollowsCurrentItem: false
        highlight: Rectangle {
            width: page.width
            height: page.rowH
            x: 0
            y: view.currentItem ? view.currentItem.y : 0
            color: tm.selectBg
            radius: 0
        }

        ScrollBar.vertical: ScrollBar {
            clip:true
            width: 20
        }
        Component.onCompleted: {
            currentIndex = 0;
            contentY = 0;
            forceActiveFocus(); //give list focus; who has it?
        }
    }
}
