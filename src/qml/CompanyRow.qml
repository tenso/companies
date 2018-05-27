import QtQuick 2.9

AListRow {
    Theme {id:tm}

    roles:  ["id", "name", "lId", "tId", "watch", "description", "aId", "maId"]
    comboModels: { "lId": listsModel, "tId": typesModel }
    inputModes: {"aId": "%"}
    colorModes: {
        "aId": { "limits": [-0.1, 0.1], "colors": [tm.fail, tm.warn, tm.ok] },
        "maId": { "limits": [0.1, 0.25], "colors": [tm.fail, tm.warn, tm.ok] }
    }
    fontColors: {
        "aId": tm.inActive,
        "maId": tm.inActive
    }
    colEdit: {"id": false, "aId": false, "maId": false}
}
