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
            property variant colW: [40, 300, 200, 80, 400]
            ListView {
                id: companiesView
                clip: true
                model: companiesModel
                anchors.fill: parent
                focus: true
                boundsBehavior: Flickable.StopAtBounds
                headerPositioning: ListView.OverlayHeader
                header: Rectangle {
                    width: page.width
                    height: 20
                    color: "#345791"
                    z:100
                    Row {
                        id: row
                        spacing: 10
                        anchors.fill: parent
                        Repeater {
                            model: page.colW
                            delegate: Text {
                                clip: true
                                maximumLineCount: 1
                                font.pixelSize: 18
                                width: page.colW[index]
                                color: "#ffffff"
                                text: companiesModel.headerData(0, companiesView.orientation, index)
                            }
                        }
                    }
                }
                delegate: Rectangle {
                    width: page.width
                    height: 20
                    color: "transparent"
                    Row {
                        width: parent.width
                        spacing: 10
                        Repeater {
                            model: [row, name, list, watch, type]
                            delegate: Text {
                                clip: true
                                maximumLineCount: 1
                                width: page.colW[index]
                                font.pixelSize: 18
                                text: modelData
                            }
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

                ScrollBar.vertical: ScrollBar {

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
