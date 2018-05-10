import QtQuick 2.9

Rectangle {
    Theme {id: tm}
    id: root
    property variant colW: []
    property int singleW: 80
    property variant itemData
    property int maximumLineCount: 1
    property font font: tm.headFont
    property alias titleH: row.height
    property color textColor: tm.headFg

    color: tm.headBg
    width: row.width
    height: row.height

    Row {
        id: row
        spacing: tm.margin
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
}

