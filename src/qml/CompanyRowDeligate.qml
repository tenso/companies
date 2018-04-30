import QtQuick 2.7

Rectangle {
    id: companyRow
    color: "transparent"
    signal select(int index)

    property variant colW: [0, 0, 0, 0, 0, 0]
    property bool showEdit: false

    Row {
        anchors.fill: parent
        spacing: 10

        CompanyCellEditText {
            width: colW[0]
            id: idText
            text: id
            enabled: companyRow.showEdit
            onEditingFinished: {
                addStatus(qsTr("id is read-only"));
                text = id;

                //id = text;
                //addStatus(qsTr("id=" + idText.text + " set id=" + text));
            }
        }
        CompanyCellEditText {
            width: colW[1]
            text: name
            enabled: companyRow.showEdit
            onEditingFinished: {
                name = text;
                addStatus(qsTr("id=" + idText.text + " set name=" + text));
            }
        }
        CompanyCellDropDown {
            showEdit: companyRow.showEdit
            comboModel: listsModel
            width: colW[2]
            text: lId
            onUpdated: {
                lId = id;
                addStatus(qsTr("id=" + idText.text + " set lId=" + id));
            }
        }
        CompanyCellDropDown {
            id: typeSelect
            showEdit: companyRow.showEdit
            comboModel: typesModel
            width: colW[3]
            text: tId
            onUpdated: {
                tId = id;
                addStatus(qsTr("id=" + idText.text + " set tId=" + id));
            }
        }
        CompanyCellEditText {
            width: colW[4]
            text: watch
            enabled: companyRow.showEdit
            onEditingFinished: {
                watch = text;
                addStatus(qsTr("id=" + idText.text + " set watch=" + text));
            }
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
