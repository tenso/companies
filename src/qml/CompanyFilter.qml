import QtQuick 2.9
import QtQuick.Controls 2.2

Rectangle {
    Theme {id: tm}
    id: companyRow
    color: tm.headBg
    property variant colW: [0, 0, 0, 0, 0, 0]
    width: filterRow.width
    height: tm.rowH

    Row {
        id: filterRow
        height: parent.height
        spacing: tm.margin
        CompanyFilterText {
            id: companyId
            index: 0
            width: colW[index]
            onTextUpdate: {
                filter = text;
            }
            prevFocus: description
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
            prevFocus: companyId
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
            prevFocus: name
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
            prevFocus: list
        }
        CompanyFilterText {
            id: watch
            index: 4
            width: colW[index]
            onTextUpdate: {
                filter = text;
            }
            prevFocus: type
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
            prevFocus: watch
        }
    }
}
