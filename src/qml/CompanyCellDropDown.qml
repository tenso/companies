import QtQuick 2.9
import QtQuick.Controls 2.2

AItem {
    id: root
    Theme{id:tm}
    width: 100
    height: tm.rowH
    property var comboModel
    property var text: itemData ? itemData[role] : ""
    property bool down: false
    property alias color: box.color
    readonly property color visibleColor: (loader.item ? loader.item.currentColor : root.color)
    readonly property string visbileText: (loader.item ? loader.item.currentText : "")
    signal updated(int id)

    onActiveFocusChanged: {
        if (activeFocus) {
            if (loader.item) {
                loader.item.forceActiveFocus();
            }
        }
    }

    Rectangle {
        id: box
        anchors.fill: parent
        color: tm.editBg(root.showEdit)

        Component {
            id: editBox

            ComboBox {
                id: comboBox
                property var currentUserText: root.text
                property color currentColor: activeFocus ? tm.focusBg : box.color
                activeFocusOnTab: false
                model: root.comboModel
                flat: true
                visible: root.showEdit
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
                        logStatus("id:" + root.itemData.id + " " + root.role + "=" + comboId);
                        //this might destroy this object (e.g re-analyse when changeing salesMode)
                        root.itemData[root.role] = comboId;
                    }
                    else {
                        root.updated(comboId);
                    }
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
            active: root.showEdit
            anchors.fill: parent
            sourceComponent: editBox
        }

        CompanyCellText {
            visible: !root.showEdit
            width: parent.width
            text: root.text
            x: 12 //this is the built in padding in the ComboBox
        }
    }
}
