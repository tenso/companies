import QtQuick 2.0

Rectangle {
    property alias model: repeater.model
    color: "#345791"
    z:100

    Row {
        spacing: 10
        anchors.fill: parent
        Repeater {
            id: repeater
            delegate: Text {
                clip: true
                verticalAlignment: Text.AlignVCenter
                maximumLineCount: 1
                font.pixelSize: 18
                width: modelData
                height: parent.height
                color: "#ffffff"
                text: index //companiesModel.headerData(0, Qt.Horizontal, index)
            }
        }
    }
}

