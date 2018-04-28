import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

ApplicationWindow {
    visible: true
    width: 1024
    height: 800
    title: qsTr("Companies")

    SwipeView {
        id: swipeView
        interactive: false
        anchors.fill: parent
        currentIndex: tabBar.currentIndex

        Page {
            id: page
            property variant colW: [40, 300, 300]

            ListView {
                id: companiesView
                clip: true
                model: companiesModel
                anchors.fill: parent
                focus: true
                boundsBehavior: Flickable.StopAtBounds
                headerPositioning: ListView.OverlayHeader
                header: Rectangle {
                    width: parent.width
                    height: 40
                    color: "#345791"
                    z:100
                    Row {
                        id: row
                        spacing: 10
                        anchors.fill: parent
                        Text {
                            clip: true
                            font.pixelSize: 24
                            width: page.colW[0]
                            color: "#ffffff"
                            text: companiesModel.headerData(0, companiesView.orientation, 0)
                        }
                        Text {
                            clip: true
                            font.pixelSize: 24
                            width: page.colW[1]
                            color: "#ffffff"
                            text: companiesModel.headerData(0, companiesView.orientation, 1)
                        }
                        Text {
                            clip: true
                            font.pixelSize: 24
                            width: page.colW[2]
                            color: "#ffffff"
                            text: companiesModel.headerData(0, companiesView.orientation, 2)
                        }
                    }
                }
                delegate: Rectangle {
                    width: parent.width
                    height: 20
                    color: "transparent"
                    Row {
                        width: parent.width
                        spacing: 10
                        Text {
                            clip: true
                            width: page.colW[0]
                            font.pixelSize: 18
                            text: row
                        }
                        Text {
                            clip: true
                            width: page.colW[1]
                            font.pixelSize: 18
                            text: name
                        }
                        Text {
                            clip: true
                            width: page.colW[2]
                            font.pixelSize: 18
                            text: list
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            companiesView.currentIndex = index;
                        }
                    }
                }

                highlight: Rectangle {
                    //y: companiesView.currentItem.y
                    anchors.fill: companiesView.currentItem
                    color: "#d0dcef"
                    radius: 2
                }
                highlightFollowsCurrentItem: false
            }
        }

        Page {
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
