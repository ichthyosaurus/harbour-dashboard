/*
 * This file is part of harbour-dashboard
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2018-2020, 2022  Mirian Margiani
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

import "../js/strings.js" as Strings
import "../js/suncalc.js" as SunCalc
import "../js/storage.js" as Storage


Column {
    id: forecast
    property string title: app.dataIsReady[locationId] ? formatTitleDate() : qsTr('Loading...')
    property bool active
    property int dayId

    width: parent.width

    Column {
        width: parent.width

        BackgroundItem {
            width: parent.width
            height: Theme.itemSizeSmall

            onClicked: active ? (
                app.dataIsReady[locationId] ? pageStack.push(
                    Qt.resolvedUrl("../pages/TablePage.qml"), { name: title, day: dayId }
                ) : console.log("table locked")
            ) : mainPage.activateGraph(dayId)

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width-x-moreImage.width-moreImage.anchors.rightMargin
                id: titleLabel
                anchors {
                    rightMargin: Theme.paddingMedium
                    verticalCenter: parent.verticalCenter
                }
                text: title
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeLarge
            }

            Image {
                id: moreImage
                anchors {
                    left: titleLabel.right
                    rightMargin: Screen.sizeCategory > Screen.Medium ? Theme.horizontalPageMargin : Theme.paddingMedium
                    verticalCenter: parent.verticalCenter
                }
                source: "image://theme/icon-m-right?" + Theme.highlightColor
            }

            Rectangle {
                anchors.fill: parent
                z: -1
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Theme.rgba(Theme.highlightBackgroundColor, 0.15) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
        }
    }

    VerticalSpacing {
        visible: active
    }

    Column {
        x: Screen.sizeCategory > Screen.Medium ? Theme.horizontalPageMargin : Theme.paddingMedium
        width: parent.width - 2*x
        height: summaryRow.height + descriptionLabel.height + spacing

        Behavior on opacity { NumberAnimation { duration: 500 } }
        opacity: graph.loaded ? 1 : 0
        visible: active

        spacing: Theme.paddingSmall

        Row {
            id: summaryRow
            width: parent.width

            Repeater {
                model: app.symbolHours.length

                ForecastSummaryItem {
                    visible: graph.loaded
                    hour: app.symbolHours[index]
                    day: dayId
                    clickedCallback: function(hour, symbol) {
                            descriptionLabel.text = String(
                                qsTr("%1: %2", "time (1) with weather description (2)")).arg(hour).arg(
                                    Strings.weatherSymbolDescription[symbol]);
                        };
                }
            }
        }

        Label {
            id: descriptionLabel
            x: 2*parent.x
            width: (isPortrait ? Screen.width : Screen.height) - 2*x

            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeSmall
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
    }

    VerticalSpacing {
        visible: active
    }

    ForecastGraphItem {
        id: graph
        visible: active
        Behavior on opacity { NumberAnimation { duration: 500 } }
        opacity: active ? 1 : 0
        day: dayId
    }

    VerticalSpacing {
        visible: active
    }

    Label {
        id: sunTitle
        text: qsTr("Sun Times")
        x: titleLabel.x
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeMedium
        visible: active
    }

    Row {
        x: sunTitle.x
        width: (isPortrait ? Screen.width : Screen.height) - 2*x
        visible: active

        Column {
            width: parent.width/2

            SunTimesItem {
                id: dawn
                label: qsTr("Dawn", "use '|' to separate alternative strings of different length").replace('|', '\x9c')
                descriptionLabel: sunDescriptionLabel
                description: qsTr("morning civil twilight starts")
            }
            SunTimesItem {
                id: sunrise
                label: qsTr("Sunrise", "use '|' to separate alternative strings of different length").replace('|', '\x9c')
                descriptionLabel: sunDescriptionLabel
                description: qsTr("top edge of the sun appears on the horizon")
            }
            SunTimesItem {
                id: morningGoldenHourEnd
                label: qsTr("Golden Hour End", "use '|' to separate alternative strings of different length").replace('|', '\x9c')
                descriptionLabel: sunDescriptionLabel
                description: qsTr("morning golden hour (soft light, best time for photography) ends")
            }
            SunTimesItem {
                id: solarNoon
                label: qsTr("Solar Noon", "use '|' to separate alternative strings of different length").replace('|', '\x9c')
                descriptionLabel: sunDescriptionLabel
                description: qsTr("sun is in the highest position")
            }
        }

        Column {
            width: parent.width/2

            SunTimesItem {
                id: eveningGoldenHour
                label: qsTr("Golden Hour", "use '|' to separate alternative strings of different length").replace('|', '\x9c')
                descriptionLabel: sunDescriptionLabel
                description: qsTr("evening golden hour (soft light, best time for photography) starts")
            }
            SunTimesItem {
                id: sunset
                label: qsTr("Sunset", "use '|' to separate alternative strings of different length").replace('|', '\x9c')
                descriptionLabel: sunDescriptionLabel
                description: qsTr("sun disappears below the horizon, evening civil twilight starts")
            }
            SunTimesItem {
                id: night
                label: qsTr("Night", "use '|' to separate alternative strings of different length").replace('|', '\x9c')
                descriptionLabel: sunDescriptionLabel
                description: qsTr("dark enough for astronomical observations")
            }
            SunTimesItem {
                id: nadir
                label: qsTr("Nadir", "use '|' to separate alternative strings of different length").replace('|', '\x9c')
                descriptionLabel: sunDescriptionLabel
                description: qsTr("darkest moment of the night, sun is in the lowest position")
            }
        }

        Component.onCompleted: {
            var locData = Storage.getLocationData(locationId);
            var date = new Date(app.forecastData[dayId].date);
            var times = SunCalc.SunCalc.getTimes(date, locData[0].latitude, locData[0].longitude);

            function set(target, value) {
                target.value = value.toLocaleString(Qt.locale(), app.timeFormat);
            }

            set(sunrise, times.sunrise);
            set(dawn, times.dawn);
            set(morningGoldenHourEnd, times.goldenHourEnd);
            set(solarNoon, times.solarNoon);
            set(eveningGoldenHour, times.goldenHour);
            set(sunset, times.sunset);
            set(night, times.night);
            set(nadir, times.nadir);
        }
    }

    VerticalSpacing {
        visible: active
    }

    Label {
        id: sunDescriptionLabel
        x: 2*sunTitle.x
        width: (isPortrait ? Screen.width : Screen.height) - 2*x
        text: " "

        color: Theme.secondaryColor
        font.pixelSize: Theme.fontSizeSmall
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        visible: active
    }

    VerticalSpacing {
        visible: active
    }

    Row {
        id: statusRow
        x: titleLabel.x
        visible: active ? (app.dataIsReady[locationId] ? true : false) : false

        property var textColor: Theme.secondaryColor
        property var textSize: Theme.fontSizeTiny

        Label {
            text: qsTr("status: ")
            color: parent.textColor
            font.pixelSize: parent.textSize
        }

        Label {
            id: statusLabel
            text: app.dataTimestamp ? app.dataTimestamp.toLocaleString(Qt.locale(), app.dateTimeFormat) : qsTr("unknown")
            color: parent.textColor
            font.pixelSize: parent.textSize
        }

        Label {
            text: " – " + qsTr("now: ")
            color: parent.textColor
            font.pixelSize: parent.textSize
        }

        Label {
            id: clockLabel
            text: new Date().toLocaleString(Qt.locale(), app.dateTimeFormat)
            color: parent.textColor
            font.pixelSize: parent.textSize
        }
    }

    VerticalSpacing {
        visible: active
    }

    function formatTitleDate() {
        return new Date(app.forecastData[dayId].date).toLocaleString(Qt.locale(), app.fullDateFormat);
    }

    function refreshTitle(data) {
        title = meteoApp ? (app.forecastData[dayId].date ? formatTitleDate() : qsTr('Failed...')) : qsTr('Failed...')

        if (statusRow) {
            statusLabel.text = (meteoApp ?
                (app.forecastData[dayId].date ?
                    app.dataTimestamp.toLocaleString(Qt.locale(), app.dateTimeFormat) : qsTr('unknown')) : qsTr('unknown'))
        }
    }

    Component.onCompleted: {
        app.dataLoaded.connect(refreshTitle)
        app.dataIsLoading.connect(function(){
            title = qsTr("Loading...");

            if (statusRow) {
                statusLabel.text = qsTr("unknown")
            }
        })
    }

    Timer {
        id: clockTimer
        interval: 15*1000
        repeat: true
        running: true
        onTriggered: {
            clockLabel.text = new Date().toLocaleString(Qt.locale(), app.dateTimeFormat)
        }
    }
}
