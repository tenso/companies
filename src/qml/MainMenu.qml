import QtQuick 2.9
import QtQuick.Controls 2.2

Rectangle {
    Theme {id: tm}
    height: tm.rowH
    width: parent.width
    color: tm.menuBg
    readonly property int nextX: menus.x + menus.width + tm.margin
    signal willSave();
    signal saveDone();

    function save() {
        willSave();
        var ok = true;
        if (companiesModel.submitAll()) {
        }
        else {
            ok = false;
        }
        if (financialsModel.submitAll()) {
        }
        else {
            ok = false;
        }

        if (analysisEngine.submitAll()) {
        }
        else {
            ok = false;
        }

        if (analysisModel.submitAll()) {
        }
        else {
            ok = false;
        }

        if (analysisResultsModel.submitAll()) {
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
        companiesModel.select();
        financialsModel.revertAll();
        financialsModel.select();
        analysisModel.revertAll();
        analysisModel.select();
        analysisResultsModel.revertAll();
        analysisResultsModel.select();
        showStatus(qsTr("Revert complete"));
    }

    function quit() {
        Qt.quit();
    }

    Shortcut {
        sequence: "Ctrl+S"
        context: Qt.ApplicationShortcut
        onActivated: save()
    }
    Shortcut {
        sequence: "Ctrl+Z"
        context: Qt.ApplicationShortcut
        onActivated: revert()
    }
    Shortcut {
        sequence: "Ctrl+Q"
        context: Qt.ApplicationShortcut
        onActivated: quit()
    }

    Row {
        id: menus
        height: tm.rowH
        AButton {
            height: parent.height
            width: tm.colW
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
}
