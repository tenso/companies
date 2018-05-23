import QtQuick 2.9

AItem {
    Theme {id:tm}
    id: root

    property variant roles: []
    property variant comboModels: ({})
    property variant inputModes: ({})
    property variant colorModes: ({})
    property variant fontColors: ({})
    property variant colEdit: ({})
    property variant colW: []
    property int singleW: 80
    property variant firstChild: null
    property variant lastChild: null
    height: tm.rowH
    width: row.width

    Row {
        id: row
        spacing: tm.margin

        Repeater {
            id: repeater
            model: root.roles

            Component {
                id: text
                CompanyCellEditText {
                    roleSelector: root.focusRole
                    itemData: root.itemData
                    showEdit: root.showEdit
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
                    showEdit: root.showEdit
                    onSelect: {
                        root.select(index)
                    }
                }
            }

            delegate: Loader {
                id: loader
                width: root.colW.length ? root.colW[index] : root.singleW
                visible: width > 0
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
                    if (typeof(colEdit[modelData]) !== "undefined") {
                        item.showEdit = colEdit[modelData];
                    }


                    if (root.lastChild) {
                        item.prevFocus = root.lastChild;
                    }
                    else {
                        root.firstChild = item;
                    }

                    root.lastChild = item;
                }
            }
        }
        Component.onCompleted: {
            if (root.firstChild) {
                if (root.prevFocus) {
                    root.firstChild.prevFocus = root.prevFocus;
                    root.prevFocus.KeyNavigation.tab = root.firstChild;
                    root.prevFocus.KeyNavigation.right = root.firstChild;
                }
                else {
                    root.firstChild.prevFocus = root.lastChild;
                }
            }
        }
    }
}
