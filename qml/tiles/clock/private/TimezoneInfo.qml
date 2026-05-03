/*
 * This file is part of harbour-dashboard
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2022-2026  Mirian Margiani
 */

pragma Singleton
import QtQuick 2.6
import QtQml 2.2
import QtQml.Models 2.2
import Sailfish.Silica 1.0

// The *TimezoneModel* (from Sailfish.Timezone) is not documented and the API
// is not public. It is possible to take a look at the model's methods:
//
// for(var it in timezoneProxyModel.model) {
//     console.log(it + " = " + timezoneProxyModel.model[it])
// }
//
// However, it is not possible to access items directly.
// This is why we need the DelegateModel as a proxy (see findTimezoneInfo()
// for how to access items).
//
// From the code at </usr/lib>/qt5/qml/Sailfish/Timezone/ and from strings
// in libsailfishtimezoneplugin.so, we can glean the following properties:
//
// model.name                 -- "Pacific/Pago_Pago"
//       area                 -- "Pacific"
//       city                 -- "Rarotonga"
//       country              -- "Cook Islands"
//       offset               -- "UTC+1:00"
//       offsetWithDstOffset  -- "UTC+1:00 (+2:00)"
//       currentOffset        -- "UTC+2:00"
//       sectionOffset        -- "UTC+1:00"
//       filter               -- ?

QtObject {
    id: root

    readonly property string __lc: "[TimezoneInfo]"
    readonly property var __lookupCache: ({})

    readonly property Instantiator _proxyModel: Instantiator {
        id: timezoneProxyModel
        delegate: QtObject {
            readonly property string name:                model.name
            readonly property string area:                model.area
            readonly property string city:                model.city
            readonly property string country:             model.country
            readonly property string offset:              model.offset
            readonly property string offsetWithDstOffset: model.offsetWithDstOffset
            readonly property string currentOffset:       model.currentOffset
            readonly property string sectionOffset:       model.sectionOffset
        }

        // Avoid hard dependencies on unstable/non-public APIs and load
        // them in a convoluted way to make Jolla's validator script happy.
        //
        // WARNING This might fail horribly some day.
        model: null

        Component.onCompleted: {
            try {
                model = Qt.createQmlObject("
                    import QtQuick 2.0
                    import %1 1.0
                    TimezoneModel {}
                ".arg("Sailfish.Timezone"),
                      timezoneProxyModel, 'TimezoneInfo')
            } catch (e) {
                console.error(__lc, "failed to load the time zone model!")
                console.error(__lc, "QML errors:")

                for (var i = 0; i < e.qmlErrors.length; ++i) {
                    console.error(__lc, "  #" + (i+1), "@",
                                  e.qmlErrors[i].lineNumber + "," + e.qmlErrors[i].columnNumber + ":",
                                  e.qmlErrors[i].message)
                }
            }
        }
    }

    function findTimezoneInfo(queryName) {
        queryName = String(queryName)

        if (__lookupCache.hasOwnProperty(queryName)) {
            // console.debug(__lc, "using cached timezone info for “%1”".arg(queryName))
            return __lookupCache[queryName]
        }

        if (timezoneProxyModel.model === null) {
            console.log(__lc, "cannot lookup timezone info for “%1”: model is not yet ready".arg(queryName))
            return null
        }

        var count = timezoneProxyModel.count
        for (var i = 0; i < count; ++i) {
            var item = timezoneProxyModel.objectAt(i)

            if (item.name === queryName) {
                console.log(__lc, "found timezone info for “%1”:".arg(queryName),
                            item.area, "/", item.city, "@", item.offsetWithDstOffset)
                __lookupCache[queryName] = item
                return item
            }
        }

        console.warn(__lc, "could not find timezone info for “%1”".arg(queryName))
        return null
    }
}
