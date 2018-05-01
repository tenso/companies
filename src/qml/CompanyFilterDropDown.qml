import QtQuick 2.7

Row {
    Theme {id: tm}
    property alias model: select.comboModel
    property int index: 0
    property string filter: ""
    signal idUpdate(string id);

    onFilterChanged: {
        companiesModel.filterColumn(index, filter)
    }

    CompanyCellDropDown {
        id: select
        color: tm.inActive
        width: parent.width - clear.width
        text: ""
        enabled: true
        onUpdated: {
            idUpdate(id);
        }
    }

    AButton {
        id: clear
        width: 20
        height: 30
        anchors.verticalCenter: select.verticalCenter
        font: tm.buttonFont

        background: Rectangle {
            color: select.down ? tm.active : tm.inActive
        }

        Image {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            width: 12
            height: 12
            source: "/assets/icons/x.svg"
        }

        onPressed: {
            select.text = "";
            idUpdate(undefined);
        }
    }
}
