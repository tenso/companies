import QtQuick 2.9

AListRow {
    Theme {id:tm}
    roles:  ["id", "name", "lId", "tId", "watch", "description", "aId"]
    comboModels: { "lId": listsModel, "tId": typesModel }
    inputModes: {"aId": "%"}
    colorModes: {
        "aId": { "limits": [-0.1, 0.1], "colors": [tm.fail, tm.warn, tm.ok] }
    }
    fontColors: {
        "aId": tm.inActive
    }
    colEdit: {"aId": false}
}
