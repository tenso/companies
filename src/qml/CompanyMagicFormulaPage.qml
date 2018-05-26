import QtQuick 2.9
import QtQuick.Controls 2.2

APage {
    id: page
    Theme {id:tm}

    onActiveChanged: {
        if (page.active) {
            if (selectedData) {
                magicModel.filterColumn("cId", "=" + selectedData.id);
            }
        }
    }

    function savePos() {
        view.savePos();
    }
    function resetPos() {
        view.resetPos();
    }

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
            if (page.active) {
                if (selectedData) {
                    magicModel.filterColumn("cId", "=" + selectedData.id);
                }
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
            snapMode: ListView.SnapToItem
            ButtonGroup {
                id: presentedGroup
            }
            delegate: CompanyMagicFormulaDelegate {
                width: view.width
                myIndex: index
                itemData: model
                buttonGroup: presentedGroup
                //FIXME: move to AItem?
                onSelect: {
                    view.currentIndex = index;
                    view.positionViewAtIndex(view.currentIndex, ListView.Contain)
                }
                checked: {
                    if (page.active && selectedData) {
                        var row = companiesModel.idToRow(selectedData.id);
                        return companiesModel.get(row, "maId") === itemData.id;
                    }
                    return false;
                }

                onSetAnalysis: {
                    if (page.active && selectedData) {
                        var row = companiesModel.idToRow(selectedData.id);
                        logDebug("set presented magic:" + selectedData.id + "=" + id);
                        companiesModel.set(row, "maId", id);
                    }
                }
            }
        }
    }
}
