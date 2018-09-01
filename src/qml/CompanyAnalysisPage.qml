import QtQuick 2.9
import QtQuick.Controls 2.2

APage {
    id: page

    onActiveChanged: {
        refresh();
    }

    function doRefresh() {
        if (page.active) {
            if (selectedData) {
                analysisModel.filterColumn("cId", "=" + selectedData.id);
                analysisEngine.selectCompany(selectedData.id);
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
            var aId = analysisEngine.newDCFAnalysis();
            if (aId < 0) {
                logError("failed to create new analysis");
            }
        }

        onWillDelete: {
            var id = analysisModel.rowToId(view.currentIndex);
            analysisEngine.delDCFAnalysis(id);
        }
    }

    SelectedCompany {
        id: head
        selectedData: page.selectedData
        colW: page.colW

        onSelectionChanged: {
            if (page.active) {
                if (selectedData) {
                    analysisModel.filterColumn("cId", "=" + selectedData.id);
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
            model: analysisModel
            anchors.fill: parent
            snapMode: ListView.SnapToItem
            ButtonGroup {
                id: presentedGroup
            }
            delegate: CompanyAnalysisDelegate {
                width: view.width
                myIndex: index
                //height: 874 //bugg? cant use page.height - head.height?
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
                        return companiesModel.get(row, "aId") === itemData.id;
                    }
                    return false;
                }
                onSetAnalysis: {
                    if (page.active && selectedData) {
                        var row = companiesModel.idToRow(selectedData.id);
                        logDebug("set presented dcf:" + selectedData.id + "=" + id);
                        companiesModel.set(row, "aId", id);
                    }
                }
            }
        }
    }
}
