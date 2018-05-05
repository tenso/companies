import QtQuick 2.7
import QtQuick.Controls 2.2

FocusScope {
    id: scope
    height: parent.height
    width: 100
    enabled: false
    property var comboModel
    property var text
    property bool down: false
    property alias color: box.color
    signal updated(int id)

    onActiveFocusChanged: {
        if (activeFocus) {
            loader.item.forceActiveFocus();
        }
    }

    Rectangle {
        id: box

        Theme {id: tm}
        anchors.fill: parent
        color: tm.editBg(enabled)

        Component {
            id: editBox

            ComboBox {
                property var currentUserText: scope.text

                onActiveFocusChanged: {
                    logStatus("combobox has focus:" + activeFocus);
                }

                id: comboBox
                activeFocusOnTab: false
                model: scope.comboModel
                flat: true
                visible: scope.enabled
                anchors.fill: parent
                textRole: "name"
                font: tm.font
                onDownChanged: {
                    scope.down = down;
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
                background: Rectangle {
                    anchors.fill: comboBox
                    color: comboBox.activeFocus ? tm.focusBg : tm.editBg(comboBox.enabled)
                }

                onActivated: {
                    scope.updated(scope.comboModel.rowToId(currentIndex));
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
            text: scope.text
        }
    }
}
