import QtQuick 2.7
import QtQuick.Controls 2.2

ListView {
    id: view
    clip: true
    focus: true
    boundsBehavior: Flickable.StopAtBounds
    keyNavigationEnabled: true

    property int _selectedRow: 0
    property int _selectedY: 0
    function savePos() {
        _selectedRow = currentIndex;
        _selectedY = contentY;
        currentIndex = -1;
    }
    function resetPos() {
        currentIndex = _selectedRow;
        contentY = _selectedY;
    }


    property var lastItem: currentItem

    onCurrentItemChanged: {
        if (lastItem) {
            lastItem.showEdit = false;
        }
        if (currentItem) {
            currentItem.showEdit = true;
        }
    }

    highlightFollowsCurrentItem: false
    highlight: Rectangle {
        width: view.width
        height: view.rowH
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
        forceActiveFocus();
    }
}
