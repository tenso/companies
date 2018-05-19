import QtQuick 2.9
import QtQuick.Controls 2.2

APage {
    id: page

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
            var aId = analysisEngine.newAnalysis(selectedData.id);
            if (aId >= 0) {
                if (!analysisEngine.analyse(aId)) {
                    logError("failed to analyse " + aId);
                }
            }
            else {
                logError("failed to create new analysis");
            }
        }

        onWillDelete: {
            var id = analysisModel.rowToId(view.currentIndex);
            analysisEngine.delAnalysis(id);
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
            delegate: CompanyAnalysisDelegate {
                width: view.width
                height: 650 //its a tradegy: can use height from ancestors...gets bugged calculating page.height.
                /*onHeightChanged: {
                    logStatus(height)
                }*/

                itemData: model

                onSelect: {
                    view.currentIndex = index;
                }
            }
        }
    }
}
