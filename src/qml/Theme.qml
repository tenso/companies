import QtQuick 2.9

QtObject {
    property int rowH: 30
    property int colW: 90
    property int wideW: 130
    property int margin: 10
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
    property color subMenuBg: "#616161"
    property color menuBg: "#515151"
    property color menuFg: "#ffffff"
    property color focusBg: graph1
    property color border: "#000000"
    property color active: "#cccccc"
    property color inActive: "#ffffff"
    property color selectBg: "#aaaaaa"

    property color graph1: "#40c639"
    property color graph2: "#0db3bc"
    property color graph3: "#c6be39"
    property color graph4: "#bc0d27"

    property color ok: graph1
    property color warn: graph3
    property color fail: graph4

    function editBg(enabled) {
        return enabled ? active : inActive;
    }
    function editFg(enabled) {
        return enabled ? textFg : textFg;
    }
}
