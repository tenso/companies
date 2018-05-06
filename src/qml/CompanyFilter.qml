import QtQuick 2.9
import QtQuick.Controls 2.2

Rectangle {
    Theme {id: tm}
    id: companyRow
    color: "transparent"
    property variant colW: [0, 0, 0, 0, 0, 0]

    Row {
        anchors.fill: parent
        spacing: 10
        anchors.leftMargin: spacing
        CompanyFilterText {
            id: companyId
            index: 0
            width: colW[index]
            onTextUpdate: {
                filter = text;
            }
            nextFocus: name
        }
        CompanyFilterText {
            id: name
            index: 1
            width: colW[index]
            onTextUpdate: {
                if (text) {
                    filter = "like '%" + text + "%'";
                } else {
                    filter = "";
                }
            }
            nextFocus: list
        }
        CompanyFilterDropDown {
            id: list
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
            nextFocus: type
        }
        CompanyFilterDropDown {
            id: type
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
            nextFocus: watch
        }
        CompanyFilterText {
            id: watch
            index: 4
            width: colW[index]
            onTextUpdate: {
                filter = text;
            }
            nextFocus: description
        }
        CompanyFilterText {
            id: description
            index: 5
            width: colW[index]
            onTextUpdate: {
                if (text) {
                    filter = "like '%" + text + "%'";
                } else {
                    filter = "";
                }
            }
            nextFocus: companyId
        }
    }
}
