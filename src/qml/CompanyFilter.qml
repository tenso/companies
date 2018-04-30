import QtQuick 2.2
import QtQuick.Controls 2.1

Rectangle {
    Theme {id: tm}
    id: companyRow
    color: "transparent"
    property variant colW: [0, 0, 0, 0, 0, 0]

    property string lId: ""
    onLIdChanged: {
        var filter = "=" + lId;
        companiesModel.filterColumn(2, filter)
        addStatus("list filter:" + filter);
    }
    property string tId: ""

    Row {
        anchors.fill: parent
        spacing: 10

        CompanyCellEditText {
            width: colW[0]
            color: tm.inActive
            onEditingFinished: {
                var filter = text;
                companiesModel.filterColumn(0, filter)
                addStatus("id filter:" + filter);
            }
        }
        CompanyCellEditText {
            width: colW[1]
            color: tm.inActive
            onEditingFinished: {
                var filter = "";
                if (text) {
                    filter = "like '%" + text + "%'";
                }
                companiesModel.filterColumn(1, filter)
                addStatus("name filter:" + filter);
            }
        }
        Row {
            CompanyCellDropDown {
                id: listSelect
                comboModel: listsModel
                color: tm.inActive
                width: colW[2] - clearList.width
                showEdit: true
                item: ""
                onUpdated: {
                    var filter = "=" + id;
                    companiesModel.filterColumn(2, filter)
                    addStatus("list filter:" + filter);
                }
            }
            AButton {
                id: clearList
                width: 15
                height: 30
                anchors.verticalCenter: listSelect.verticalCenter
                font.pixelSize: 24
                text: "x"
                onPressed: {
                    listSelect.item = ""
                    var filter = "";
                    companiesModel.filterColumn(2, filter)
                    addStatus("list filter:" + filter);
                }
            }
        }
        Row {
            CompanyCellDropDown {
                id: typeSelect
                color: tm.inActive
                comboModel: typesModel
                width: colW[3] - clearType.width
                item: tId
                showEdit: true
                onUpdated: {
                    var filter = "=" + id;
                    companiesModel.filterColumn(3, filter)
                    addStatus("type filter:" + filter);
                }
            }
            AButton {
                id: clearType
                width: 15
                height: 30
                anchors.verticalCenter: typeSelect.verticalCenter
                font.pixelSize: 24
                text: "x"
                onPressed: {
                    typeSelect.item = ""
                    var filter = "";
                    companiesModel.filterColumn(3, filter)
                    addStatus("type filter:" + filter);
                }
            }
        }
        CompanyCellEditText {
            color: tm.inActive
            width: colW[4]
            onEditingFinished: {
                var filter = text;
                companiesModel.filterColumn(4, filter)
                addStatus("watch filter:" + filter);
            }
        }
        CompanyCellEditText {
            color: tm.inActive
            width: colW[5]
            onEditingFinished: {
                var filter = "";
                if (text) {
                    filter = "like '%" + text + "%'";
                }
                companiesModel.filterColumn(5, filter)
                addStatus("desc filter:" + filter);
            }
        }
    }
}
