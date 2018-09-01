import QtQuick 2.9
import QtQuick.Controls 2.2

Page {
    property variant selectedData
    property variant colW: []
    property int rowCount: 0
    property bool active: false

    function refresh() {
        refreshTimer.start();
    }

    Timer {
        id: refreshTimer
        running: false
        interval: 1
        repeat: false
        onTriggered: {
            if (typeof(doRefresh) === "function") {
                doRefresh();
            }
        }
    }
}
