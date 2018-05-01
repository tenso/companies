import QtQuick 2.7
import QtQuick.Controls 2.2

Rectangle {
    Theme {id: tm}
    id: dropDown
    signal updated(int id)
    color: tm.editBg(enabled)
    enabled: false
    property bool down: false
    height: parent.height
    width: 100
    property var comboModel
    property var text

    Component {
        id: editBox

        ComboBox {
            property var currentUserText: dropDown.text
            id: comboBox
            model: comboModel
            flat: true
            visible: dropDown.enabled
            anchors.fill: parent
            textRole: "name"
            font: tm.font
            onDownChanged: {
                dropDown.down = down;
            }

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
                currentIndex = find(currentUserText);
            }
            onCurrentUserTextChanged: {
                currentIndex = find(currentUserText);
            }
        }
    }
    Loader {
        id: loader
        active: parent.enabled
        anchors.fill: parent
        sourceComponent: editBox
    }

    CompanyCellText {
        visible: !parent.enabled
        width: parent.width
        text: parent.text
    }
}
