import QtQuick 2.7
import QtQuick.Controls 2.2

Rectangle {
    Theme {id: tm}
    id: companyRow
    color: "transparent"
    property variant colW: [0, 0, 0, 0, 0, 0]

    Row {
        anchors.fill: parent
        spacing: 10

        CompanyFilterText {
            index: 0
            width: colW[index]
            onTextUpdate: {
                filter = text;
            }
        }
        CompanyFilterText {
            index: 1
            width: colW[index]
            onTextUpdate: {
                if (text) {
                    filter = "like '%" + text + "%'";
                } else {
                    filter = "";
                }
            }
        }
        CompanyFilterDropDown {
            model: listsModel
            index: 2
            width: colW[index]
            onIdUpdate: {
                if (id) {
                    filter = "=" + id;
                }
                else {
                    filter = "";
                }
            }
        }
        CompanyFilterDropDown {
            model: typesModel
            index: 3
            width: colW[index]
            onIdUpdate: {
                if (id) {
                    filter = "=" + id;
                }
                else {
                    filter = "";
                }
            }
        }
        CompanyFilterText {
            index: 4
            width: colW[index]
            onTextUpdate: {
                filter = text;
            }
        }
        CompanyFilterText {
            index: 5
            width: colW[index]
            onTextUpdate: {
                if (text) {
                    filter = "like '%" + text + "%'";
                } else {
                    filter = "";
                }
            }
        }
    }
}
