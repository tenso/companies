import QtQuick 2.9

AItem {
    id: root
    clip: true
    property string role: ""
    property string filter: ""
    property alias inputMode: select.inputMode
    signal textUpdate(string text);
    height: row.height
    onFilterChanged: {
        companiesModel.filterColumn(role, filter)
    }

    Row {
        id: row
        width: parent.width
        Theme {id: tm}

        CompanyCellEditText {
            id: select
            color: tm.inActive
            width: parent.width - clear.width
            showEdit: true
            focus: true
            onUpdated: {
                root.textUpdate(text);
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
                root.textUpdate(undefined);
            }
        }
    }
}
