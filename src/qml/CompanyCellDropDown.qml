import QtQuick 2.7
import QtQuick.Controls 2.2

Rectangle {
    Theme {id: tm}
    id: dropDown
    signal updated(int id)
    color: tm.editColor(showEdit)

    property bool showEdit: false
    height: parent.height
    width: 100
    property var comboModel
    property var item

    Component {
        id: editBox

        ComboBox {
            property var currentItem: dropDown.item
            id: comboBox
            model: comboModel
            flat: true
            visible: showEdit
            anchors.fill: parent
            textRole: "name"
            font: tm.font
            delegate: ItemDelegate {
                width: comboBox.width
                height: tm.selectRowH
                contentItem: Text {
                    text: name
                    color: tm.textFg
                    font: tm.selectFont
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
                highlighted: comboBox.highlightedIndex === index
            }

            onActivated: {
                updated(comboModel.rowToId(currentIndex));
            }
            Component.onCompleted: {
                currentIndex = find(currentItem);
            }
            onCurrentItemChanged: {
                currentIndex = find(currentItem);
            }
        }
    }
    Loader {
        id: loader
        active: showEdit
        anchors.fill: parent
        sourceComponent: editBox
    }

    CompanyCellText {
        visible: !showEdit
        width: parent.width
        text: parent.item
    }
}
