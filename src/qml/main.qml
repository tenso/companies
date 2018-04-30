import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

ApplicationWindow {
    Theme {id:tm}
    id: window
    visible: true
    width: 1280
    height: 800
    title: qsTr("Companies")
    property string status: ""
    header: MainMenu {}

    function addStatus(text) {
        status = "[" + new Date().toTimeString() + "] " + text;
    }

    SwipeView {
        id: swipeView
        interactive: false
        anchors.fill: parent
        currentIndex: tabBar.currentIndex

        Page {
            id: page
            property int totColW: window.width - 5*10
            property int rowH: tm.rowH
            property variant colW: [60, 300, 200, 200, 70, totColW - 840]

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
                id: companiesView
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
                        lastItem.showEdit = false
                    }
                    currentItem.showEdit = true
                }

                delegate: CompanyRowDeligate {
                    width: page.width
                    height: page.rowH
                    colW: page.colW

                    onSelect: {
                        companiesView.currentIndex = index;
                        companiesView.forceActiveFocus();
                    }
                }

                highlightFollowsCurrentItem: false
                highlight: Rectangle {
                    width: page.width
                    height: page.rowH
                    x: 0
                    y: companiesView.currentItem.y
                    color: tm.selectColor
                    radius: 0
                }

                ScrollBar.vertical: ScrollBar {
                    clip:true
                    width: 20
                }
                Component.onCompleted: {
                    positionViewAtBeginning();
                    currentIndex = 0;
                    forceActiveFocus(); //give list focus; who has it?
                }
            }

        }

        Page {
            ColumnLayout{
                anchors.centerIn: parent
                Row{
                    Label {
                        text: qsTr("Second page")
                        font: tm.font
                    }
                }
                Row {
                    Label {
                        text: qsTr("Second page")
                        font: tm.buttonFont
                    }
                }
            }
        }
    }

    footer: Rectangle {
        width: parent.width
        height: 40
        color: tm.menuBg
        TabBar {
            height: 20
            width: parent.width
            id: tabBar
            currentIndex: swipeView.currentIndex
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
            text: companiesView.count
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
            text: status
            font: tm.font
        }
    }
}
