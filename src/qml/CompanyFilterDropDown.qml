import QtQuick 2.9

AItem {
    id: root
    height: row.height
    property alias model: select.comboModel
    property string role: ""
    property string filter: ""
    signal textUpdate(string text);

    onFilterChanged: {
        companiesModel.filterColumn(role, filter)
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
            showEdit: true
            onUpdated: {
                root.textUpdate(visbileText); //dont use 'id' filters use related value!
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
                root.textUpdate("");
            }
        }
    }
}
