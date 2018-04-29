import QtQuick 2.0
import QtQuick.Controls 2.0

Rectangle {
    color: "transparent"
    signal select(int index)
    id: companyRow
    property variant colW: [0, 0, 0, 0, 0, 0]
    property bool showEdit: false
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
            model: [id, name, lId, tId, watch, description]
            property variant canEdit: [0, 0, 0, 1, 0, 0]
            delegate: Item {
                id: cell
                width: companyRow.colW[index]
                height: parent.height

                Component {
                    id: editBox

                    ComboBox {
                        flat: true
                        visible: showEdit
                        anchors.fill: parent
                        model: {
                            if (index === 3) typesModel;
                            else [{name: "fix"}, {name: "me"}];
                        }
                        textRole: "name"
                        font.pixelSize: 18
                        onCurrentIndexChanged: {
                            if (down) {
                                if (index === 3) {
                                    tId = typesModel.rowToId(currentIndex);
                                }
                                else {
                                    console.log("ERROR: unimplemented, FIXME");
                                }
                            }
                        }
                        Component.onCompleted: {
                            if (index === 3) {
                                currentIndex = find(tId);
                            }
                            else {
                                currentIndex = 0;
                            }
                        }
                    }
                }
                Loader {
                    id: loader
                    active: cells.canEdit[index] && showEdit
                    anchors.fill: parent
                    sourceComponent: editBox
                }

                Text {
                    id: text
                    clip: true
                    visible: !loader.active || !showEdit
                    anchors.centerIn: parent
                    maximumLineCount: 1
                    width: companyRow.colW[index]
                    font.pixelSize: 18
                    text: modelData
                }
            }
        }
    }
}
