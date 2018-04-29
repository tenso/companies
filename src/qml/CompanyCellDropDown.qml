import QtQuick 2.0
import QtQuick.Controls 2.2

Item {
    id: dropDown
    signal updated(int id)

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
            font.pixelSize: 18
            onCurrentIndexChanged: {
                if (down) {
                    updated(comboModel.rowToId(currentIndex));
                }
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
