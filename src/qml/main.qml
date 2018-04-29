import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

ApplicationWindow {
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
            property int rowH: 30
            property variant colW: [40, 300, 180, 300, 70, 300]
            ListView {
                id: companiesView
                clip: true
                model: companiesModel
                anchors.fill: parent
                focus: true
                boundsBehavior: Flickable.StopAtBounds
                keyNavigationEnabled: true

                property var lastItem: currentItem

                onCurrentIndexChanged: {
                    if (lastItem !== null) {
                        lastItem.showEdit = false
                    }
                    currentItem.showEdit = true
                }

                headerPositioning: ListView.OverlayHeader
                header: CompanyHeaderDeligate {
                    width: page.width
                    height: page.rowH
                    model: page.colW
                }

                delegate: CompanyRowDeligate {
                    width: page.width
                    height: page.rowH
                    colW: page.colW

                    onSelect: companiesView.currentIndex = index;
                }

                highlightFollowsCurrentItem: false
                highlight: Rectangle {
                    anchors.fill: companiesView.currentItem
                    color: "#d0dcef"
                    radius: 0
                }

                ScrollBar.vertical: ScrollBar {
                }
                Component.onCompleted: {
                    positionViewAtBeginning();
                    currentIndex = 0;
                }

            }
        }

        Page {
            ComboBox {
                currentIndex: 1
                editable: true
                model: ["one", "two", "three"]
            }
            Label {
                text: qsTr("Second page")
                anchors.centerIn: parent
            }
        }
    }

    footer: Item {
        width: parent.width
        height: 40
        TabBar {
            height: 20
            width: parent.width
            id: tabBar
            currentIndex: swipeView.currentIndex
            TabButton {
                height: parent.height
                text: qsTr("List")
            }
            TabButton {
                height: parent.height
                text: qsTr("Details")
            }
        }
        Text {
            id: statusBar
            anchors.top: tabBar.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: 10
            width: parent.width
            text: status
        }
    }
}
