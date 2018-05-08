import QtQuick 2.9

AItem {
    id: root
    height: row.height
    property alias model: select.comboModel
    property int index: 0
    property string filter: ""
    signal idUpdate(string id);

    onFilterChanged: {
        companiesModel.filterColumn(index, filter)
    }

    Row {
        id: row
        Theme {id: tm}
        width: root.width

        CompanyCellDropDown {
            id: select
            focus: true
            color: tm.inActive
            width: parent.width - clear.width
            text: ""
            enabled: true
            onUpdated: {
                root.idUpdate(id);
            }
        }

        AButton {
            id: clear
            width: 20
            height: 30
            anchors.verticalCenter: select.verticalCenter
            font: tm.buttonFont

            background: Rectangle {
                color: select.visibleColor
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
                root.idUpdate(undefined);
            }
        }
    }
}
