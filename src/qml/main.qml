import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

ApplicationWindow {
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
            property int rowH: 30
            property variant colW: [totColW * 0.05, totColW * 0.25,
                totColW * 0.2, totColW * 0.2, totColW * 0.05, totColW * 0.25]

            ListView {
                id: companiesView
                clip: true
                model: companiesModel
                anchors.fill: parent
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

                headerPositioning: ListView.OverlayHeader
                header: CompanyHeaderDeligate {
                    width: page.width
                    height: page.rowH
                    colW: page.colW
                    model: [qsTr("Id"), qsTr("Name"), qsTr("List"), qsTr("Type"), qsTr("Watch"), qsTr("Description")]
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
                    color: "#d0dcef"
                    radius: 0
                }

                ScrollBar.vertical: ScrollBar {
                }
                Component.onCompleted: {
                    positionViewAtBeginning();
                    currentIndex = 0;
                    forceActiveFocus(); //give list focus; who has it?
                }
            }
        }

        Page {
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
