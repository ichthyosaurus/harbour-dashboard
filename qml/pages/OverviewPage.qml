/*
 * This file is part of harbour-dashboard
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2018-2020, 2022  Mirian Margiani
 */

import QtQuick 2.6
import Sailfish.Silica 1.0
import "../components"

import "../js/storage.js" as Storage
import "../js/strings.js" as Strings

Page {
    id: overviewPage
    allowedOrientations: Orientation.All

    signal loadingFinished(var locationId)
    signal dataUpdated(var newData, var locationId)

    function getTemperatureString(temperature) {
        return (temperature === undefined) ? "" : temperature + " °C";
    }

    function addLocationToModel(locationData, temperature, symbol) {
        if (!locationData) {
            console.log("error: failed to add location to model: invalid data")
            return
        }

        locationsModel.append({
            "locationId": locationData.locationId,
            "zip": locationData.zip,
            "name": locationData.name,
            "canton": locationData.canton,
            "cantonId": locationData.cantonId,
            "temperatureString": getTemperatureString(temperature),
            "symbol": symbol,
        })
    }

    function addLocation(locationData) {
        console.log("add location", locationData.locationId, locationData.name);

        var res = Storage.addLocation(locationData, locationsModel.count);

        if (res > 0) {
            addLocationToModel(locationData, undefined, undefined)
        }

        app.refreshData(locationData.locationId, true)
    }

    SilicaListView {
        id: locationsListView
        anchors.fill: parent

        property int itemCount: locationsModel.count
        onItemCountChanged: if (itemCount === 0) placeholder.enabled = true;

        ListModel { id: locationsModel }
        model: locationsModel

        header: PageHeader { title: app.appName }
        VerticalScrollDecorator { flickable: locationsListView }

        footer: VerticalSpacing { }

        PullDownMenu {
            Component.onCompleted: {
                overviewPage.dataUpdated.connect(function(newData, locationId) {
                    var readyList = Object.keys(app.dataIsReady).map(function(k) { return app.dataIsReady[k]; });
                    if (readyList.every(function(k) { return k ? true : false; })) {
                        busy = false
                    }
                });
                app.dataIsLoading.connect(function() { busy = true; });
            }

            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }

            MenuItem {
                text: qsTr("Add location")
                onClicked: pageStack.push(Qt.resolvedUrl("LocationSearchPage.qml"))
            }

            MenuItem {
                text: qsTr("Refresh")
                visible: locationsModel.count > 0
                onClicked: {
                    app.refreshData(undefined, false);
                }
            }

            Label {
                id: clockLabel
                text: new Date().toLocaleString(Qt.locale(), app.dateTimeFormat)
                color: Theme.highlightColor
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        ViewPlaceholder {
            id: placeholder
            enabled: (locationsModel.count === 0 && Storage.getLocationsCount() === 0)
            text: qsTr("Add a location first")
            hintText: qsTr("Pull down to add items")
        }

        delegate: OverviewListDelegate {
            parentModel: locationsModel
            Component.onCompleted: {
                refreshWeekSummary();
                loadingFinished.connect(function(loc) {
                    if (locationId === loc) {
                        refreshWeekSummary();
                        console.log("refreshing:", loc)
                    }
                });
            }
        }

        Component.onCompleted: {
            console.log("loading all known locations...")
            var locs = Storage.getLocationData()
            for (var i = 0; i < locs.length; i++) {
                var summary = Storage.getDataSummary(locs[i].locationId)
                addLocationToModel(locs[i], summary.temperature, summary.symbol)
            }
        }
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

    Timer {
        id: refreshTimer
        interval: 60*15*1000 // every 15 minutes
        repeat: true
        running: true
        onTriggered: {
            if (overviewPage.status === PageStatus.Active) {
                app.refreshData(undefined, false);
            }
        }
    }

    onStatusChanged: {
        // refresh everything; probably not necessary
        if (overviewPage.status === PageStatus.Active) {
            dataUpdated(undefined, undefined);
        }
    }

    onDataUpdated: {
        if (locationId && !app.dataIsReady[locationId]) {
            console.log("summary not updated: data is not ready yet", app.dataIsReady[locationId], locationId);
            return;
        }

        for (var i = locationsModel.count-1; i >= 0; i--) {
            if (!locationId || (locationId === locationsModel.get(i).locationId)) {
                console.log("updating overview summary... " + i);
                var loc = locationsModel.get(i).locationId;
                var summary = Storage.getDataSummary(loc);
                locationsModel.setProperty(i, 'temperatureString', getTemperatureString(summary.temp));
                locationsModel.setProperty(i, 'symbol', summary.symbol);
                loadingFinished(loc);
            }
        }
    }

    Component.onCompleted: {
        app.dataLoaded.connect(dataUpdated)
        app.locationAdded.connect(addLocation)
    }
}
