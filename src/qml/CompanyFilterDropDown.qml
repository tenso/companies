import QtQuick 2.7

Row {
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
        showEdit: true
        onUpdated: {
            idUpdate(id);
        }
    }
    AButton {
        id: clear
        width: 15
        height: 30
        anchors.verticalCenter: select.verticalCenter
        font: tm.buttonFont

        Image {
            anchors.centerIn: parent
            width: 10
            height: 10
            source: "/assets/icons/x.svg"
        }

        onPressed: {
            select.text = "";
            idUpdate(undefined);
        }
    }

}
