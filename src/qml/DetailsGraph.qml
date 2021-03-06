import QtQuick 2.9
import QtQuick.Controls 2.2
import QtCharts 2.2

import "Util.js" as Util

Rectangle {
    Theme{id:tm}
    id: dataPlot
    width: 100
    height: 100
    clip: true
    property var model
    property string categoryRole
    property var showOrder

    property string filterRole: ""
    property variant filterEqValue

    property var _showVisible
    property var setColors: ({})

    onShowOrderChanged: {
        var i;
        _showVisible = {};
        for(i = 0; i < showOrder.length; i++) {
            _showVisible[showOrder[i]] = true;
        }
    }

    function redraw() {
        //chartView.fillAll();
        redrawTimer.restart();
    }

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
        target: dataPlot.model
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

    ChartView {
        id: chartView

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: dataToShow.top

        legend.visible: false

        StackedBarSeries {
            id: barChart

            axisX: BarCategoryAxis {
            }
            axisY: ValueAxis {
                min: 0
                max: 1
                tickCount: 5
            }
        }


        function addData(row, role, cat, data, colH) {
            var val = dataPlot.model.get(row, role);

            if(val !== "" && cat >= 0) {
                data[role][cat] = val;
                colH[cat] += Math.ceil(val);
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
            var cats = [];

            //remake cats
            if (dataPlot.categoryRole !== "") {
                for (i = 0; i < dataPlot.model.rowCount(); i++) {
                    year = dataPlot.model.get(i, dataPlot.categoryRole);
                    if (year === "") {
                        continue;
                    }

                    if (filterRole !== "") {
                        q = dataPlot.model.get(i, filterRole);
                        if (q !== filterEqValue) {
                            continue;
                        }
                    }

                    cat = cats.indexOf(parseInt(year));
                    if (cat < 0) {
                        cats.push(parseInt(year));
                    }
                }
                Util.sort(cats, true);
            }

            //remake data
            for (i = 0; i < dataPlot.showOrder.length; i++) {
                data[dataPlot.showOrder[i]] = Util.newArray(cats.length, 0);
            }

            if (cats.length) {
                colH = Util.newArray(cats.length, 0);

                for (i = 0; i < dataPlot.model.rowCount(); i++) {
                    year = dataPlot.model.get(i, dataPlot.categoryRole);
                    cat = cats.indexOf(parseInt(year));
                    if (cat < 0) {
                        continue;
                    }

                    for (j = 0; j < dataPlot.showOrder.length; j++) {
                        role = dataPlot.showOrder[j];
                        if (dataPlot._showVisible[role]) {
                            addData(i, role, cat, data, colH);
                        }
                    }
                }
                maxColH = Util.max(colH);
            }
            if (maxColH <= 0) {
                maxColH = 1; //barChart.axisY=0 -> segfaults
            }

            barChart.clear();
            barChart.axisX.categories = cats;
            barChart.axisY.max = maxColH;
            if (maxColH >= 0) {
                for (i = 0; i < dataPlot.showOrder.length; i++) {
                    role = dataPlot.showOrder[i];
                    if (dataPlot._showVisible[role]) {
                        barSet = barChart.insert(i, role, data[role]);
                        barSet.color = dataPlot.setColors[role] ? dataPlot.setColors[role] : tm.graph1;
                    }
                }
            }
        }
    }
    Row {
        id: dataToShow
        height: tm.rowH
        anchors.bottom: parent.bottom
        anchors.bottomMargin: tm.rowH
        anchors.horizontalCenter: parent.horizontalCenter
        Repeater {
            model: dataPlot.showOrder
            delegate: ACheckBox {
                id: control
                checked: true
                text: modelData
                checkColor: {
                    dataPlot.setColors[modelData] ? dataPlot.setColors[modelData] : tm.graph1
                }

                onCheckedChanged: {
                    dataPlot._showVisible[modelData] = checked;
                    redrawTimer.restart();
                }
            }
        }
    }
}
