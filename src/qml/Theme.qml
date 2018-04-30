import QtQuick 2.7

QtObject {
    property int rowH: 30
    property int selectRowH: 26

    //"Roboto Medium", "Roboto Light", "Roboto Thin", "Roboto Black", "Roboto"
    property string fontFamily: "Roboto"
    property font selectFont: Qt.font({
        family: fontFamily,
        pixelSize: 14
    })
    property font font: Qt.font({
        family: fontFamily,
        pixelSize: 18
    })
    property font headFont: Qt.font({
        family: "Roboto Black",
        pixelSize: 18
    })
    property font buttonFont: Qt.font({
        family: fontFamily,
        pixelSize: 24
    })

    property color bg: "#ffffff"
    property color textFg: "#000000"
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
