import QtQuick 2.0
import QtQuick.Controls 2.0

Rectangle {
    color: "transparent"
    signal select(int index)
    id: companyRow
    property variant colW: [0, 0, 0, 0, 0]

    MouseArea {
        anchors.fill: parent
        onClicked: {
            select(index)
        }
    }

    Row {
        anchors.fill: parent
        spacing: 10
        Repeater {
            id: cells
            model: [row, name, list, watch, type]
            property variant canEdit: [0, 0, 0, 0, 1]
            delegate: Item {
                width: companyRow.colW[index]
                height: parent.height
                Text {
                    id: text
                    clip: true
                    visible: !cells.canEdit[index]
                    anchors.centerIn: parent
                    maximumLineCount: 1
                    width: companyRow.colW[index]
                    font.pixelSize: 18
                    text: modelData
                }

                ComboBox {
                    flat: true
                    visible: cells.canEdit[index]
                    anchors.fill: parent
                    currentIndex: 1
                    model: ["one", "two", "three"]
                    onCurrentIndexChanged:  {
                        type = currentIndex;
                    }
                }
            }
        }
    }
}
