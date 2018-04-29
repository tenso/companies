import QtQuick 2.7
import QtQuick.Controls 2.2

Item {
    height: 30
    width: parent.width

    function save()
    {
        companiesModel.submitAll();
        addStatus(qsTr("Save complete"))
    }

    function revert()
    {
        companiesModel.revertAll();
        addStatus(qsTr("Revert complete"))
    }

    function quit()
    {
        Qt.quit();
    }

    Shortcut {
        sequence: "Ctrl+S"
        onActivated: save()
    }
    Shortcut {
        sequence: "Ctrl+Z"
        onActivated: revert()
    }
    Shortcut {
        sequence: "Ctrl+Q"
        onActivated: quit()
    }

    Button {
        flat: true
        height: parent.height
        text: qsTr("File")
        onClicked: menu.open()
        Menu {
            id: menu

            MenuItem {
                text: qsTr("Save")
                ToolTip {
                    text: qsTr("Ctrl+S")
                    delay: 500
                    visible: parent.hovered
                }
                onTriggered: save()
            }
            MenuItem {
                ToolTip {
                    text: qsTr("Ctrl+Z")
                    delay: 500
                    visible: parent.hovered
                }
                text: qsTr("Revert")
                onTriggered: revert()
            }
            MenuItem {
                text: qsTr("Quit")
                ToolTip {
                    text: qsTr("Ctrl+Q")
                    delay: 500
                    visible: parent.hovered
                }
                onTriggered: quit();
            }
        }
    }
}
