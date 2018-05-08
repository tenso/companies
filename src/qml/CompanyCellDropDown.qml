import QtQuick 2.9
import QtQuick.Controls 2.2

AItem {
    id: root
    Theme{id:tm}
    width: 100
    height: tm.rowH
    enabled: false
    property var comboModel
    property var text: itemData ? itemData[role] : ""
    property bool down: false
    property alias color: box.color
    readonly property color visibleColor: (loader.item ? loader.item.currentColor : root.color)
    signal updated(int id)

    onActiveFocusChanged: {
        if (activeFocus) {
            loader.item.forceActiveFocus();
        }
    }

    Rectangle {
        id: box
        anchors.fill: parent
        color: tm.editBg(enabled)

        Component {
            id: editBox

            ComboBox {
                id: comboBox
                property var currentUserText: root.text
                property color currentColor: activeFocus ? tm.focusBg : box.color
                activeFocusOnTab: false
                model: root.comboModel
                flat: true
                visible: root.enabled
                anchors.fill: parent
                textRole: "name"
                font: tm.font
                onDownChanged: {
                    root.down = down;
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
                    color: comboBox.currentColor
                }

                onActivated: {
                    var comboId = root.comboModel.rowToId(currentIndex);
                    if (root.itemData && root.role !== "") {
                        root.itemData[root.role] = comboId;
                        logStatus("id:" + root.itemData.id + " " + root.role + "=" + comboId);
                    }
                    root.updated(comboId);
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
            text: root.text
        }
    }
}
