/*
 * This file is part of harbour-dashboard
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2018-2020, 2022  Mirian Margiani
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

import "../modules/qchart/"
import "../modules/qchart/QChart.js" as Charts


QChart {
    id: windChart
    property bool scaleOnly: false
    property bool isToday: false

    chartAnimated: false
    chartData: wind ? wind : { labels: [], datasets: [{ fillColor: "rgba(0,0,0,0)", strokeColor: "rgba(0,0,0,0)", pointColor: "rgba(0,0,0,0)", data: [] }]}
    chartType: Charts.ChartType.LINE
    chartOptions: ({
        scaleFontSize: Theme.fontSizeExtraSmall,
        scaleFontFamily: 'Sail Sans Pro',
        scaleFontColor: Theme.secondaryColor,
        scaleLineColor: Theme.secondaryColor,
        scaleOverlay: scaleOnly,
        bezierCurve: true,
        scaleStartValue: 0,
        datasetStrokeWidth: 2,
        pointDot: false,
        currentHourLine: isToday,

        fillColor: ["rgba(0,0,0,0)"],
        strokeColor: ["rgba(255,255,0,1)"],
        pointColor: ["rgba(255,255,0,1)"],
        pointStrokeColor: ["rgba(255,255,0,1)"],
    })
}
