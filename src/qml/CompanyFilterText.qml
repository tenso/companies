import QtQuick 2.7

FocusScope {
    id: scope
    property int index: 0
    property string filter: ""
    signal textUpdate(string text);
    height: row.height
    onFilterChanged: {
        companiesModel.filterColumn(index, filter)
    }

    Row {
        id: row
        width: parent.width
        Theme {id: tm}

        CompanyCellEditText {
            id: select
            color: tm.inActive
            width: parent.width - clear.width
            focus: true
            onUpdated: {
                scope.textUpdate(text);
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
                scope.textUpdate(undefined);
            }
        }
    }
}
