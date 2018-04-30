import QtQuick 2.0

Item {
    property color headBg: "#515151"
    property color headFg: "#ffffff"
    property color menuBg: "#515151"
    property color menuFg: "#ffffff"
    property color active: "#cccccc"
    property color inActive: "#ffffff"
    property color selectColor: "#aaaaaa"

    function editColor(enabled) {
        return enabled ? active : inActive;
    }
}
