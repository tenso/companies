import QtQuick 2.9

Rectangle {
    Theme {id: tm}
    id: root
    property variant colW: []
    property int singleW: 80
    property alias model: repeater.model
    color: tm.headBg
    signal filterChange(int index, string filter)
    property bool filterEnabled: false
    Row {
        spacing: 10
        width: parent.width
        anchors.top: parent.top
        height: 30
        id: nameRow
        Repeater {
            id: repeater
            delegate: CompanyCellText {
                font: tm.headFont
                horizontalAlignment: Text.AlignHCenter
                id: name
                color: tm.headFg
                text: modelData
                width: root.colW.length ? root.colW[index] : root.singleW
                height: parent.height
            }
        }
    }


    CompanyFilter {
        visible: filterEnabled
        anchors.top: nameRow.bottom
        height: 30
        colW: parent.colW
    }
}

