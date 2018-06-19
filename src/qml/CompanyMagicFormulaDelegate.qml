import QtQuick 2.9
import QtQuick.Controls 2.2

AItem {
    Theme {id:tm}

    property variant buttonGroup
    property int myIndex: 0
    property alias checked: checkButton.checked
    id: root
    width: tm.wideW
    height: tm.rowH * 4 + separator.height + tm.margin

    signal setAnalysis(int id);

    Rectangle {
        id: bg
        anchors.fill: parent
        color: "transparent"

        Text {
            id: idText
            width: tm.wideW
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: tm.margin * 2
            anchors.topMargin: tm.margin
            text: itemData ? "(" + itemData.id + ")" : ""
        }
        ARadioButton {
            id: checkButton
            anchors.left: idText.left
            anchors.top: idText.bottom
            anchors.topMargin: tm.margin
            ButtonGroup.group: buttonGroup
            onCheckedChanged: {
                setAnalysis(root.itemData.id)
            }
        }
        Rectangle {
            id: separator
            color: tm.headBg
            width: parent.width
            height: 1
            anchors.bottom: parent.bottom
        }
    }

    CompanyDetailGroup {
        id: m1
        anchors.left: parent.left
        anchors.leftMargin: tm.rowH * 3 + tm.margin
        itemData: root.itemData
        itemW: tm.wideW
        groupName: ""
        headerModel: [qsTr("Financials from"), qsTr("Year"), qsTr("Quarter"), qsTr("Ebit"), qsTr("EV"), qsTr("Cap. Employed"), qsTr("Score")]
        itemRoles:  ["financialsMode", "year", "qId", "ebit", "ev", "capitalEmployed", "score"]
        colorModes: {
            "score": { "limits": [0.15, 0.3], "colors": [tm.fail, tm.warn, tm.ok] }
        }
        fontColors: {
            "score": tm.inActive
        }
        colEdit: {"score": false}
        itemCombos: {"financialsMode": calcModesManModel, "qId": quartersModel };
    }
}

