import QtQuick 2.9
import QtQuick.Controls 2.2

Rectangle {
    Theme {id:tm}
    id: bar
    width: parent.width
    height: tm.rowH + 20
    color: tm.menuBg
    property alias currentTab: tabBar.currentIndex
    property alias lastLog: statusBar.text
    property string statusText: ""
    signal showStatus();

    TabBar {
        currentIndex: 0 //debug!
        height: tm.rowH
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
        anchors.leftMargin: tm.margin
        width: parent.width / 2
        text: parent.statusText
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
        anchors.rightMargin: tm.margin
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
