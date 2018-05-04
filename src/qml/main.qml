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
    function addStatus(text) {
        var dateTag = "[" + new Date().toTimeString() + "]";
        status = text + " " + dateTag;
        statusLog = statusLog + "\n" + dateTag + " " + text;
    }

    header: MainMenu {
        onWillSave: {
            overview.savePos();
        }
        onSaveDone: {
            overview.resetPos();
        }
    }

    Component.onCompleted: {
        addStatus("load all");
        companiesModel.fetchAll();
    }

    SwipeView {
        id: pages
        interactive: false
        anchors.fill: parent
        currentIndex: statusBar.currentTab

        property int totColW: window.width - 5*10
        property int rowH: tm.rowH
        property variant colW: [70, 300, 300, 300, 70, totColW - 1060]

        CompanyOverviewPage {
            id: overview
            rowH: pages.rowH
            colW: pages.colW
        }

        CompanyDetailsPage {
            id: details
            rowH: pages.rowH
            colW: [70, 300, 300, 300, 70, pages.totColW - (1060 + pages.rowH)]
            selectedData: overview.currentItemData
        }
    }

    footer: MainStatusBar {
        id: statusBar
        currentTab: pages.currentIndex
        rowCount: overview.count
        statusText: window.status
        onShowStatus: {
            statusPopup.open();
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
                text: window.statusLog
            }
            ScrollBar.vertical: ScrollBar {}
            ScrollBar.horizontal: ScrollBar {}
        }
    }
}
