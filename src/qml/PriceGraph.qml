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
            chartView.maxYear = -999999999;
            chartView.minYear = 999999999;
            chartView.maxY = -999999999;
            chartView.minY = 999999999;
            chartView.fillAll(finChart, financialsModel, "year", "sharePrice");
            chartView.fillAll(analysisChart, analysisModel, "year", "shareValue");
        }
    }

    ChartView {
        id: chartView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        //legend.visible: false

        property int maxYear: -999999999
        property int minYear: 999999999
        property int maxY: -999999999
        property int minY: 999999999

        axes: [
            ValueAxis {
                id: xAxis
                min: 0
                max: 1
                titleText: qsTr("Year")
                labelFormat: "%4i"
                tickCount: 5
            },
            ValueAxis {
                id: yAxis
                min: 0
                max: 1
                titleText: qsTr("Price")
                tickCount: 5
            }
        ]


        LineSeries {
            id: finChart
            name: qsTr("Share price")
            axisX: xAxis
            axisY: yAxis
        }
        LineSeries {
            id: analysisChart
            name: qsTr("DCF value")
            axisX: xAxis
            axisY: yAxis
        }

        function fillAll(chart, model, modelYear, modelY) {
            chart.clear();

            var i = 0;
            var year;
            var y;
            var set;
            var q;
            var added = false;

            for (i = 0; i < model.rowCount(); i++) {
                year = model.get(i, modelYear);
                if (year === "")  continue;
                year = parseInt(year);
                q = model.get(i, "qId");
                if (q === "") continue;

                q = parseFloat(q) / 4.0;

                if (year < minYear) {
                    minYear = year;
                }
                if (year > maxYear) {
                    maxYear = year;
                }

                y = model.get(i, modelY);
                if (y < minY) {
                    minY = y;
                }
                if (y > maxY) {
                    maxY = y;
                }

                set = chart.insert(i, year + q, y);
                added = true;
                //logStatus((year + q) + ":" + y);
            }

            if (added && model.rowCount() === 1) {
                set = chart.insert(i, year - 1, y);
            }

            //update axis
            xAxis.max = maxYear;
            xAxis.min = minYear;
            xAxis.tickCount = (maxYear - minYear) + 1;

            yAxis.max = maxY + 10;
            yAxis.min = minY - 10;
        }
    }
}
