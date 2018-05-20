import QtQuick 2.9
import QtQuick.Controls 2.2

APage {
    id: page

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
            var aId = analysisEngine.newDCFAnalysis(selectedData.id);
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
            if (selectedData) {
                analysisModel.filterColumn("cId", "=" + selectedData.id);
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
                height: 874 //bugg? cant use page.height - head.height?
                itemData: model
                buttonGroup: presentedGroup
                onSelect: {
                    view.currentIndex = index;
                }
                checked: {
                    if (selectedData) {
                        var row = companiesModel.idToRow(selectedData.id);
                        return companiesModel.get(row, "aId") === itemData.id;
                    }
                    return false;
                }
                onSetAnalysis: {
                    if (selectedData) {
                        var row = companiesModel.idToRow(selectedData.id);
                        logStatus("set presented:" + selectedData.id + "=" + id);
                        companiesModel.set(row, "aId", id);
                    }
                }
            }
        }
    }
}
