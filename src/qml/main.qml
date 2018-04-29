import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

ApplicationWindow {
    visible: true
    width: 1280
    height: 800
    title: qsTr("Companies")

    SwipeView {
        id: swipeView
        interactive: false
        anchors.fill: parent
        currentIndex: tabBar.currentIndex

        Page {
            id: page
            property int rowH: 30
            property variant colW: [40, 300, 200, 80, 400]
            ListView {
                id: companiesView
                clip: true
                model: companiesModel
                anchors.fill: parent
                focus: true
                boundsBehavior: Flickable.StopAtBounds

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

                    onSelect: {
                        companiesView.currentIndex = index;
                    }
                }

                highlightFollowsCurrentItem: false
                highlight: Rectangle {
                    anchors.fill: companiesView.currentItem
                    color: "#d0dcef"
                    radius: 2
                }

                ScrollBar.vertical: ScrollBar {

                }
            }
        }

        Page {
            ComboBox {
                currentIndex: 1
                model: ["one", "two", "three"]
            }
            Label {
                text: qsTr("Second page")
                anchors.centerIn: parent
            }
        }
    }

    footer: TabBar {
        id: tabBar
        currentIndex: swipeView.currentIndex
        TabButton {
            text: qsTr("List")
        }
        TabButton {
            text: qsTr("Details")
        }
    }
}
