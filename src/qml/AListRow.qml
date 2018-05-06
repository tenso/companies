import QtQuick 2.9

AListItem {
    id: root
    signal select(int index)
    property variant roles: []
    property variant comboModels: ({})
    property variant colW: []
    property int singleW: 80
    height: 30

    Row {
        id: row
        anchors.fill: parent
        spacing: 10
        anchors.leftMargin: 10

        Repeater {
            id: repeater
            model: root.roles
            property variant prevLoad: null
            property variant firstChild: null

            Component {
                id: text
                CompanyCellEditText {
                    width: parent.width
                    roleSelector: root.focusRole
                    model: root.itemData
                    enabled: root.showEdit
                }
            }
            Component {
                id: dropDown
                CompanyCellDropDown {
                    width: parent.width
                    roleSelector: root.focusRole
                    model: root.itemData
                    enabled: root.showEdit
                }
            }

            delegate: Loader {
                id: loader
                width: root.colW.length ? root.colW[index] : root.singleW
                height: root.height
                sourceComponent:  comboModels[modelData] ? dropDown : text
                onLoaded: {
                    item.role = modelData;

                    if (comboModels[modelData]) {
                        item.comboModel = comboModels[modelData];
                    }

                    if (repeater.prevLoad) {
                        item.prevFocus = repeater.prevLoad;
                    }
                    else {
                        repeater.firstChild = item;
                    }

                    repeater.prevLoad = item;
                }
            }
        }
        Component.onCompleted: {
            repeater.firstChild.prevFocus = repeater.prevLoad;
        }
    }
    MouseArea {
        anchors.fill: parent
        enabled: !showEdit
        onClicked: {
            select(index);
        }
    }
}
