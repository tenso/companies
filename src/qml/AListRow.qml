import QtQuick 2.9

AItem {
    Theme {id:tm}
    id: root

    property variant roles: []
    property variant comboModels: ({})
    property variant inputModes: ({})
    property variant colorModes: ({})
    property variant fontColors: ({})
    property variant colW: []
    property int singleW: 80
    height: tm.rowH
    width: row.width

    Row {
        id: row
        spacing: tm.margin

        Repeater {
            id: repeater
            model: root.roles
            property variant prevLoad: null
            property variant firstChild: null

            Component {
                id: text
                CompanyCellEditText {
                    roleSelector: root.focusRole
                    itemData: root.itemData
                    enabled: root.showEdit
                    onSelect: {
                        root.select(index)
                    }
                }
            }
            Component {
                id: dropDown
                CompanyCellDropDown {
                    roleSelector: root.focusRole
                    itemData: root.itemData
                    enabled: root.showEdit
                    onSelect: {
                        root.select(index)
                    }
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
                    if (inputModes[modelData]) {
                        item.inputMode = inputModes[modelData];
                    }
                    if (colorModes[modelData]) {
                        item.colorMode = colorModes[modelData];
                    }
                    if (fontColors[modelData]) {
                        item.fontColor = fontColors[modelData];
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
            if (repeater.firstChild) {
                repeater.firstChild.prevFocus = repeater.prevLoad;
            }
        }
    }
}
