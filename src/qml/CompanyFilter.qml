import QtQuick 2.9
import QtQuick.Controls 2.2

Rectangle {
    Theme {id: tm}
    id: companyRow
    color: tm.headBg
    property variant colW: [0, 0, 0, 0, 0, 0, 0]
    width: filterRow.width
    height: tm.rowH

    Row {
        id: filterRow
        height: parent.height
        spacing: tm.margin
        CompanyFilterText {
            id: companyId
            role: "id"
            width: colW[0]
            onTextUpdate: {
                filter = text;
            }
            prevFocus: description
        }
        CompanyFilterText {
            id: name
            role: "name"
            width: colW[1]
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
            role: "lId"
            model: listsModel
            width: colW[2]
            onTextUpdate: {
                if (text) {
                    filter = "=" + text;
                }
                else {
                    filter = "";
                }
            }
            prevFocus: name
        }
        CompanyFilterDropDown {
            id: type
            role: "tId"
            model: typesModel
            width: colW[3]
            onTextUpdate: {
                if (text) {
                    filter = "=" + text;
                }
                else {
                    filter = "";
                }
            }
            prevFocus: list
        }
        CompanyFilterText {
            id: watch
            role: "watch"
            width: colW[4]
            onTextUpdate: {
                filter = text;
            }
            prevFocus: type
        }
        CompanyFilterText {
            id: description
            role: "description"
            width: colW[5]
            onTextUpdate: {
                if (text) {
                    filter = "like '%" + text + "%'";
                } else {
                    filter = "";
                }
            }
            prevFocus: watch
        }
        CompanyFilterText {
            id: rebate
            role: "aId"
            width: colW[6]
            onTextUpdate: {
                filter = text;
            }
            prevFocus: type
        }
    }
}
