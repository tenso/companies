import QtQuick 2.7

Rectangle {
    Theme {id: tm}
    property variant colW: []
    property alias model: repeater.model
    color: tm.headBg
    z:100
    signal filterChange(int index, string filter)

    Row {
        spacing: 10
        width: parent.width
        anchors.top: parent.top
        height: 30
        id: nameRow
        Repeater {
            id: repeater
            delegate: Item {
                width: colW[index]
                height: parent.height
                CompanyCellText {
                    id: name
                    color: tm.headFg
                    width: colW[index]
                    text: modelData
                    height: parent.height
                }
            }
        }
    }


    CompanyFilter {
        anchors.top: nameRow.bottom
        height: 30
        colW: parent.colW
    }
}

