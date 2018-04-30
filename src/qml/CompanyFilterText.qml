import QtQuick 2.7

Row {
    property int index: 0

    property string filter: ""
    signal textUpdate(string text);

    onFilterChanged: {
        companiesModel.filterColumn(index, filter)
    }

    CompanyCellEditText {
        id: edit
        color: tm.inActive
        width: parent.width - clear.width
        onEditingFinished: {
            textUpdate(text);
        }
    }
    AButton {
        width: 15
        height: 30
        font: tm.buttonFont
        text: "x"
        id: clear
        anchors.verticalCenter: edit.verticalCenter
        onPressed: {
            edit.text = "";
            textUpdate(edit.text);
        }
    }
}
