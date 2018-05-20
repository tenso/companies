import QtQuick 2.9
import QtQuick.Controls 2.2

APage {
    id: page
    Theme {id:tm}
    DataMenu {
        id: controls
        x: pageMenuX
        y: pageMenuY
        active: page.active
        enabled: page.selectedData ? true : false
        view: view

        onWillCreate: {
            if (!selectedData) {
                logError("no selection");
                return;
            }
            var aId = analysisEngine.newMagicAnalysis(selectedData.id);
            if (aId < 0) {
                logError("failed to magic analyse " + aId);
            }
        }

        onWillDelete: {
            var id = magicModel.rowToId(view.currentIndex);
            analysisEngine.delMagicAnalysis(id);
        }
    }

    SelectedCompany {
        id: head
        selectedData: page.selectedData
        colW: page.colW

        onSelectionChanged: {
            if (selectedData) {
                magicModel.filterColumn("cId", "=" + selectedData.id);
            }
        }
    }
    Rectangle {
        id: analysis
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: head.bottom
        anchors.bottom: parent.bottom
        color: tm.inActive

        AList {
            id: view
            model: magicModel
            anchors.fill: parent
            anchors.leftMargin: tm.rowH * 3 + tm.margin
            snapMode: ListView.SnapToItem
            delegate: CompanyDetailGroup {
                itemData: model
                width: view.width
                height: tm.rowH * 3
                groupName: ""
                focusRole: ""
                showEdit: false
                headerModel: [qsTr("Ebit"), qsTr("EV"), qsTr("Cap. Employed"), qsTr("Score")]
                itemRoles:  ["ebit", "ev", "capitalEmployed", "score"]
                colorModes: {
                    "score": { "limits": [0.1, 0.25], "colors": [tm.fail, tm.warn, tm.ok] }
                }
                fontColors: {
                    "score": tm.inActive
                }
                colEdit: {"score": false}
                itemW: tm.wideW
                onSelect: {
                    view.currentIndex = index;
                }
            }
        }
    }
}
