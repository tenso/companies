import QtQuick 2.2

Rectangle {
    id: companyRow
    color: "transparent"
    signal select(int index)

    property variant colW: [0, 0, 0, 0, 0, 0]
    property bool showEdit: false

    Row {
        anchors.fill: parent
        spacing: 10

        CompanyCellText {
            id: idText
            width: colW[0]
            text: id
        }
        CompanyCellText {
            width: colW[1]
            text: name
        }
        CompanyCellText {
            width: colW[2]
            text: lId
        }
        CompanyCellDropDown {
            showEdit: companyRow.showEdit
            comboModel: typesModel
            width: colW[3]
            item: tId
            onUpdated: {
                tId = id;
                addStatus(qsTr("id=" + idText.text + " set tId=" + id));
            }
        }
        CompanyCellText {
            width: colW[4]
            text: watch
        }
        CompanyCellEditText {
            width: colW[5]
            text: description
            enabled: companyRow.showEdit
            onEditingFinished: {
                description = text;
                addStatus(qsTr("id=" + idText.text + " set desc=" + text));
            }
        }
    }
    MouseArea {
        anchors.fill: parent
        enabled: !showEdit
        onClicked: {
            select(index);
        }
    }
}
