import QtQuick 2.7
import QtQuick.Controls 2.2

Rectangle {
    Theme {id:tm}
    id: bar
    width: parent.width
    height: 40
    color: tm.menuBg
    property alias currentTab: tabBar.currentIndex
    property alias statusText: statusBar.text
    property int rowCount: 0
    signal showStatus();

    TabBar {
        currentIndex: 1 //debug!
        height: 20
        width: parent.width
        id: tabBar
        ATabButton {
            text: qsTr("List")
        }
        ATabButton {
            text: qsTr("Details")
        }
    }
    Text {
        id: countBar
        color: tm.menuFg
        anchors.top: tabBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.leftMargin: 10
        width: parent.width / 2
        text: "Rows: " + parent.rowCount
        font: tm.font
    }
    Text {
        id: statusBar
        color: tm.menuFg
        horizontalAlignment: Text.AlignRight
        anchors.top: tabBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: countBar.right
        anchors.right: parent.right
        anchors.rightMargin: 10
        font: tm.font
        clip: true
        elide: Text.ElideRight
        MouseArea {
            anchors.fill: parent
            onPressed: {
                bar.showStatus();
            }
        }
    }
}
