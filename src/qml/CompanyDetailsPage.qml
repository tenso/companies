import QtQuick 2.9
import QtQuick.Controls 2.2
import QtCharts 2.2

Page {
    id: page
    Theme {id:tm}
    property alias selectedData: currentCompany.itemData
    property alias rowCount: view.count
    property variant colW: []


    Rectangle {
        id: head
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: tm.rowH + tm.margin * 2
        color: tm.headBg

        CompanyHeaderDeligate {
            id: listHead
            width: page.width
            colW: page.colW
            x: tm.margin
            y: tm.margin
            itemData: [qsTr("Id"), qsTr("Name"), qsTr("List"), qsTr("Type"), qsTr("Watch"), qsTr("Description")]
        }

        AListRow {
            id: currentCompany
            roles:  ["id", "name", "lId", "tId", "watch", "description"]
            comboModels: { "lId": listsModel, "tId": typesModel }
            itemData: overview.currentItemData
            anchors.left: parent.left
            anchors.leftMargin: tm.margin
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: tm.margin
            showEdit: true
            colW: page.colW
            onItemDataChanged: {
                if (itemData) {
                    financialsModel.filterColumn(1, "=" + itemData.id);
                }
                chartView.fillAll();
            }
        }
    }
    AListControls {
        id: controls
        anchors.top: head.bottom
        model: financialsModel
        addId: currentCompany.itemData ? currentCompany.itemData.id : -1;
        addIdCol: 1
        enabled: currentCompany.itemData
        view: view
    }
    Rectangle {
        id: financials
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: controls.bottom
        height: tm.rowH * 10 + view.spacing
        color: tm.headBg

        AList {
            id: view
            model: financialsModel
            anchors.fill: parent
            snapMode: ListView.SnapToItem
            //spacing: tm.margin
            delegate: CompanyDetailsDeligate {
                width: view.width
                itemData: model

                onSelect: {
                    view.currentIndex = index;
                }
            }
        }
    }
    Rectangle {
        id: dataPlot
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: financials.bottom
        anchors.bottom: parent.bottom

        property var showOrder: ["sales", "ebit", "dividend"]
        property var showVisible: {"sales": true, "ebit": true, "dividend": true}
        property var setColors: {"sales": tm.graph2, "ebit": tm.graph1, "dividend": tm.graph3}

        Timer {
            id: redrawTimer
            running: false
            interval: 250
            repeat: false
            onTriggered: {
                chartView.fillAll();
            }
        }

        Connections {
            target: financialsModel
            onDataChanged: {
                redrawTimer.restart();
            }
            onRowsRemoved: {
                redrawTimer.restart();
            }
            onRowsInserted: {
                redrawTimer.restart();
            }
        }

        Row {
            id: dataToShow
            anchors.left: parent.left
            anchors.right: parent.right
            height: tm.rowH
            Repeater {
                model: dataPlot.showOrder
                delegate: CheckBox {
                    id: control
                    checked: true
                    text: modelData

                    indicator: Rectangle {
                        implicitWidth: 26
                        implicitHeight: 26
                        x: control.leftPadding
                        y: parent.height / 2 - height / 2
                        radius: 3
                        border.color: tm.border

                        Rectangle {
                            width: 14
                            height: 14
                            x: 6
                            y: 6
                            radius: 2
                            color: dataPlot.setColors[modelData]
                            visible: control.checked
                        }
                    }

                    onCheckedChanged: {
                        dataPlot.showVisible[modelData] = checked;
                        redrawTimer.restart();
                    }
                }
            }
        }

        ChartView {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.top: dataToShow.bottom

            id: chartView
            //legend.alignment: Qt.AlignBottom
            legend.visible: false
            //title: qsTr("Summary")

            StackedBarSeries {
                id: barChart

                axisX: BarCategoryAxis {
                }
                axisY: ValueAxis {
                    min: 0
                    max: 100
                    tickCount: 5
                }
            }

            //FIXME: generalize helper js functions!
            function newArray(len, initial) {
                var i;
                var a = [];
                for (i = 0; i < len; i++) {
                    a[i] = initial;
                }
                return a;
            }

            function addData(row, role, cat, data, colH) {
                var val = financialsModel.get(row, role);

                if(val !== "" && cat >= 0) {
                    data[role][cat] = val;
                    colH[cat] += parseInt(val);
                }
            }

            function fillAll() {
                var data = ({});
                var colH;
                var key = "";
                var i;
                var j;
                var maxColH = 0;
                var cat;
                var insertIndex;
                var year;
                var q;
                var role;
                var barSet;
                //remake cats
                var cats = [];
                for (i = 0; i < financialsModel.rowCount(); i++) {
                    year = financialsModel.get(i, "year");
                    q = financialsModel.get(i, "qId");
                    if (year === "" || q !== "FY") {
                        continue;
                    }
                    cat = cats.indexOf(parseInt(year));
                    if (cat < 0) {
                        cats.push(parseInt(year));
                    }
                }
                cats = cats.sort(function(a,b) { return a-b;});

                //remake data
                for (i = 0; i < dataPlot.showOrder.length; i++) {
                    data[dataPlot.showOrder[i]] = newArray(cats.length, 0);
                }

                if (cats.length) {
                    colH = newArray(cats.length, 0);

                    for (i = 0; i < financialsModel.rowCount(); i++) {
                        year = financialsModel.get(i, "year");
                        q = financialsModel.get(i, "qId");
                        if (year === "" || q !== "FY") {
                            continue;
                        }
                        cat = cats.indexOf(parseInt(year));
                        if (cat < 0) {
                            logError("category not found");
                            continue;
                        }
                        for (j = 0; j < dataPlot.showOrder.length; j++) {
                            role = dataPlot.showOrder[j];
                            if (dataPlot.showVisible[role]) {
                                addData(i, role, cat, data, colH);
                            }
                        }
                    }

                    maxColH = colH.reduce(function(a,b) { return Math.max(a, b);});
                }

                barChart.clear();
                barChart.axisX.categories = cats;
                barChart.axisY.max = maxColH ? maxColH : 1;
                if (maxColH >= 0) {
                    for (i = 0; i < dataPlot.showOrder.length; i++) {
                        role = dataPlot.showOrder[i];
                        if (dataPlot.showVisible[role]) {
                            barSet = barChart.insert(i, role, data[role]);
                            barSet.color = dataPlot.setColors[role];
                        }
                    }
                }
            }

            Component.onCompleted: {
                fillAll();
            }
        }
    }
}
