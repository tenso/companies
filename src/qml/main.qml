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
    property string statusLog: ""
    property int selectedRow: 0
    property int selectedY: 0
    property int reSelectList: 0
    header: MainMenu {}

    function addStatus(text) {
        var dateTag = "[" + new Date().toTimeString() + "]";
        status = text + " " + dateTag;
        statusLog = statusLog + "\n" + dateTag + " " + text;
    }

    Component.onCompleted: {
        addStatus("load all");
        companiesModel.fetchAll();
    }

    onReSelectListChanged: {
        companiesView.currentIndex = selectedRow;
        companiesView.contentY = selectedY;
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
            property variant colW: [70, 300, 300, 300, 70, totColW - 1060]

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
                    itemData: model
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

        Page {

            CompanyRowDeligate {
                id: currentCompany
                itemData: companiesView.currentItem.itemData

                anchors.top: parent.top
                showEdit: true
                width: page.width
                height: page.rowH
                colW: page.colW
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
            text: "Rows: " + companiesView.count
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
            clip: true
            elide: Text.ElideRight
            MouseArea {
                anchors.fill: parent
                onPressed: {
                    statusPopup.open();
                }
            }
        }
    }
    Popup {
        id: statusPopup
        visible: false

        height: parent.height / 2
        width: 400
        x: parent.width - width
        y: parent.height - height

        Flickable {
            anchors.fill: parent
            contentHeight: logTextArea.height
            contentWidth: logTextArea.width
            boundsBehavior: Flickable.StopAtBounds
            clip:true
            TextArea {
                id: logTextArea
                font: tm.font
                readOnly: true
                text: statusLog
            }
            ScrollBar.vertical: ScrollBar {}
            ScrollBar.horizontal: ScrollBar {}
        }
    }
}
