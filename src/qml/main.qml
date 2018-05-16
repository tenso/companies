import QtQuick 2.9
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

    function showStatus(text) {
        console.log("USER " + text);
        addStatus("USER " + text);
    }

    function logStatus(text) {
        console.log("STATUS " + text);
        addStatus("STATUS " + text);
    }

    function logError(text) {
        console.log("ERROR " + text);
        addStatus("ERROR " + text);
    }

    MainMenu {
        id: mainMenu
        onWillSave: {
            overview.savePos();
        }
        onSaveDone: {
            overview.resetPos();
        }
    }

    property int pageMenuX: mainMenu.nextX
    property int pageMenuY: -mainMenu.height

    Component.onCompleted: {
        showStatus(qsTr("Load all done"));
    }

    StackLayout {
        id: pages
        anchors.fill: parent
        anchors.topMargin: mainMenu.height
        currentIndex: statusBar.currentTab

        property int totColW: window.width - 5*10
        property variant colW: [70, 300, 300, 300, 70, pages.totColW - 1060]

        CompanyOverviewPage {
            id: overview
            colW: pages.colW
            active: pages.currentIndex == 0
        }

        CompanyDetailsPage {
            id: details
            colW: pages.colW
            selectedData: overview.selectedData
            active: pages.currentIndex == 1
        }
        CompanyAnalysisPage {
            id: analysis
            colW: pages.colW
            selectedData: overview.selectedData
            active: pages.currentIndex == 2
        }
    }

    footer: MainStatusBar {
        id: statusBar
        currentTab: pages.currentIndex
        statusText: "Total: " + overview.rowCount + ", finacial entries:" + details.rowCount;
        lastLog: window.status
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
