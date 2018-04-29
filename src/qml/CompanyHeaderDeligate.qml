import QtQuick 2.7

Rectangle {
    property variant colW: []
    property alias model: repeater.model
    color: "#345791"
    z:100

    Row {
        spacing: 10
        anchors.fill: parent
        Repeater {
            id: repeater
            delegate: CompanyCellText {
                color: "#ffffff"
                width: colW[index]
                text: modelData
            }
        }
    }
}

