/*
 * This file is part of harbour-dashboard
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2018-2020, 2022  Mirian Margiani
 */

import QtQuick 2.6
import Sailfish.Silica 1.0

SilicaItem {
    id: root

    property alias label: topLabel.text
    property alias description: bottomLabel.text
    property bool inverted: false
    property alias truncationMode: topLabel.truncationMode
    property alias maximumLineCount: topLabel.maximumLineCount

    property alias labelFont: topLabel.font
    property alias descriptionFont: bottomLabel.font
    property alias horizontalAlignment: topLabel.horizontalAlignment

    readonly property alias topLabelItem: topLabel
    readonly property alias bottomLabelItem: bottomLabel

    property bool preferHighlightColors: false
    property alias topLabelColor: topLabel.color
    property alias bottomLabelColor: bottomLabel.color

    property alias topLabelPalette: topLabel.palette
    property alias bottomLabelPalette: bottomLabel.palette

    implicitWidth: Math.max(topLabel.implicitWidth, bottomLabel.implicitWidth)
    height: childrenRect.height

    Label {
        id: topLabel
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        font.pixelSize: Theme.fontSizeMedium
        color: (highlighted || preferHighlightColors) ? palette.highlightColor : palette.primaryColor
        wrapMode: Text.Wrap
        maximumLineCount: 2
        truncationMode: TruncationMode.Fade

        visible: !!text
        height: visible ? (topMetrics.width > width ? 2 * topMetrics.height : topMetrics.height) : 0

        TextMetrics {
            id: topMetrics
            text: topLabel.text
            font.pixelSize: topLabel.font.pixelSize
        }
    }

    Label {
        id: bottomLabel
        visible: !!text
        anchors {
            top: topLabel.bottom
            topMargin: 0
            left: parent.left
            right: parent.right
        }

        font.pixelSize: Theme.fontSizeSmall
        color: (highlighted || preferHighlightColors) ? palette.secondaryHighlightColor : palette.secondaryColor
        // truncationMode: root.truncationMode
        height: visible ? implicitHeight : 0
        wrapMode: Text.Wrap
        maximumLineCount: root.maximumLineCount
        horizontalAlignment: topLabel.horizontalAlignment
    }

    states: State {
        name: "inverted"
        when: inverted

        PropertyChanges { target: topLabel; anchors.topMargin: 0 }
        PropertyChanges { target: bottomLabel; anchors.topMargin: 0 }

        AnchorChanges {
            target: bottomLabel
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
        }

        AnchorChanges {
            target: topLabel
            anchors {
                top: bottomLabel.bottom
                left: parent.left
                right: parent.right
            }
        }
    }
}
