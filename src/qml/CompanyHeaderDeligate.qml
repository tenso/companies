import QtQuick 2.9

Rectangle {
    Theme {id: tm}
    id: root
    property variant colW: []
    property int singleW: 80
    property variant itemData
    property bool filterEnabled: false
    property int maximumLineCount: 1
    property font font: tm.headFont
    property alias titleH: row.height
    property color textColor: tm.headFg
    signal filterChange(int index, string filter)

    color: tm.headBg
    width: row.width
    height: row.height + (filter.visible ? filter.height : 0)

    Row {
        id: row
        spacing: 10
        height: tm.rowH
        Repeater {
            id: repeater
            model: root.itemData
            delegate: CompanyCellText {
                maximumLineCount: root.maximumLineCount
                font: root.font
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignBottom
                id: name
                color: root.textColor
                text: modelData
                width: root.colW.length ? root.colW[index] : root.singleW
                height: row.height
            }
        }
    }

    CompanyFilter {
        id: filter
        visible: filterEnabled
        anchors.top: row.bottom
        height: tm.rowH
        colW: parent.colW
    }
}

