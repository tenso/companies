import QtQuick 2.9
import QtQuick.Controls 2.2

Rectangle {
    Theme {id: tm}
    height: 30
    width: parent.width
    color: tm.menuBg
    signal willSave();
    signal saveDone();

    function save() {
        willSave();
        var ok = true;
        if (companiesModel.submitAll()) {
            companiesModel.fetchAll();
        }
        else {
            ok = false;
        }
        if (financialsModel.submitAll()) {
            financialsModel.fetchAll();
        }
        else {
            ok = false;
        }

        if (ok) {
            showStatus(qsTr("Save successfull"));
        }
        else {
            showStatus(qsTr("Save failed"));
        }

        saveDone();
    }

    function revert() {
        companiesModel.revertAll();
        financialsModel.revertAll();
        financialsModel.select();
        showStatus(qsTr("Revert complete"));
    }

    function quit() {
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

    AButton {
        height: parent.height
        width: 100
        text: qsTr("File")
        onClicked: menu.open()
        font: tm.font
        Menu {
            id: menu

            MenuItem {
                font: tm.font
                text: qsTr("Save")
                ToolTip {
                    font: tm.font
                    text: qsTr("Ctrl+S")
                    delay: 500
                    visible: parent.hovered
                }
                onTriggered: save()
            }
            MenuItem {
                font: tm.font
                ToolTip {
                    font: tm.font
                    text: qsTr("Ctrl+Z")
                    delay: 500
                    visible: parent.hovered
                }
                text: qsTr("Revert")
                onTriggered: revert()
            }
            MenuItem {
                font: tm.font
                text: qsTr("Quit")
                ToolTip {
                    font: tm.font
                    text: qsTr("Ctrl+Q")
                    delay: 500
                    visible: parent.hovered
                }
                onTriggered: quit();
            }
        }
    }
}
