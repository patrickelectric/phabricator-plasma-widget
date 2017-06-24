/***************************************************************************
 *   Copyright (C) 2017 by Enoque Joseneas <enoquejoseneas@gmail.com>      *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.0
import org.kde.plasma.components 2.0 as PlasmaComponents

PlasmaComponents.Page {
    clip: true; anchors.fill: parent

    property bool requestInProgress: false

    function getPriorityTaskColor(priority) {
        if (priority === "Unbreak Now!")
            return "#da49be";
        else if (priority === "Needs Triage")
            return "#8e44ad";
        else if (priority === "Hight")
            return "#c0392b";
        else if (priority === "Normal")
            return "#e67e22";
        else if (priority === "Low")
            return "#f1c40f";
        return "#3498db";
    }

    function maniphestPageRequest() {
        if (requestInProgress || !settings.token.length || !settings.userPhabricatorId.length)
            return;
        requestInProgress = true;
        var params = "api.token=%1".arg(settings.token);
        if (settings.projectId)
            params += "&constraints[projects][0]=%1".arg(settings.projectId);
        else if (settings.userPhabricatorId)
            params += "&constraints[assigned][0]=%1".arg(settings.userPhabricatorId);
        jsonModel.requestParams = params;
        jsonModel.source += "maniphest.search";
        jsonModel.load(function(response) {
            requestInProgress = false;
            if (jsonModel.httpStatus == 200 && response.result) {
                if (maniphestView.count > 0 && maniphestView.count !== response.result.data.length) {
                    var fixBind = [];
                    maniphestView.model = fixBind;
                    systemTrayNotification.showMessage(qsTr("Phabricator Widget"), qsTr("New task(s) for you! Take a look in Phabricator widget!"));
                }
                maniphestView.model = response.result.data;
            }
        });
    }

    // timer to reload tasks
    Timer {
        id: updateCheckTimer
        interval: 500000; running: true; repeat: true
        onTriggered: maniphestPageRequest()
    }

    Connections {
        target: settings
        onReady: maniphestPageRequest()
        onProjectIdChanged: maniphestPageRequest()
    }

    Rectangle {
        id: preview
        clip: true; anchors.fill: parent
        color: "transparent"; visible: false

        property int requestId: 0
        property var previewObject: {
            "fields": {"name": ""},
            "description": {"raw": ""}
        }

        onRequestIdChanged: {
            if (!requestId)
                return;
            jsonModel.source += "maniphest.search";
            jsonModel.requestParams = "api.token=%1&constraints[ids][0]=%2".arg(settings.token).arg(requestId);
            jsonModel.load(function(response) {
                if (jsonModel.httpStatus == 200 && response.result && response.result.data.length) {
                    preview.previewObject = response.result.data[0];
                    preview.visible = true;
                }
            })
        }

        Image {
            id: backButtonImg
            width: 24; height: width
            asynchronous: true; clip: true
            source: "../images/arrow_back.svg"
            anchors { left: parent.left; leftMargin: 5; top: parent.top; topMargin: 5 }

            MouseArea {
                onClicked: preview.visible = false
                anchors.fill: parent; hoverEnabled: true
                onEntered: cursorShape = Qt.PointingHandCursor
            }

            ColorOverlay {
                anchors.fill: backButtonImg
                source: backButtonImg; color: detailTextLabel.color; cached: true
            }
        }

        Column {
            clip: true
            spacing: 20
            width: parent.width * 0.90
            anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 30 }

            PlasmaComponents.Label {
                id: detailTextLabel
                width: parent.width
                elide: Text.ElideRight
                text: preview.previewObject.fields.name
            }

            PlasmaComponents.Label {
                width: parent.width
                elide: Text.ElideRight
                text: typeof preview.previewObject.description != "undefined" ? preview.previewObject.description.raw : ""
            }
        }
    }

    ListView {
        id: maniphestView
        anchors.fill: parent
        visible: !preview.visible
        clip: true; spacing: 0
        ScrollIndicator.vertical: ScrollIndicator { }
        delegate: Rectangle {
            clip: true; color: "transparent"
            width: parent.width; height: 50

            RowLayout {
                anchors { fill: parent; verticalCenter: parent.verticalCenter }

                // show phabricator priority task color
                Rectangle {
                    width: 4; height: parent.height-5
                    color: getPriorityTaskColor(modelData.fields.priority.name);
                    anchors { left: parent.left; leftMargin: 0; verticalCenter: parent.verticalCenter }
                }

                // show the task title
                Rectangle  {
                    color: "transparent"
                    width: parent.width * 0.80; height: parent.height

                    PlasmaComponents.Label {
                        id: taskTitle
                        width: parent.width
                        elide: Text.ElideRight
                        text: modelData.fields.name
                        anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                    }
                }

                // show the task priority name
                PlasmaComponents.Label {
                    color: taskTitle.color
                    text: modelData.fields.priority.name
                    height: parent.height
                    font.pointSize: 7; opacity: 0.7
                    anchors { right: parent.right; rightMargin: 5; top: parent.top; topMargin: 3 }
                }

                // show the task created datetime
                PlasmaComponents.Label {
                    color: taskTitle.color
                    text: Qt.formatDateTime(new Date(modelData.fields.dateCreated*1000))
                    font.pointSize: 7; opacity: 0.7
                    anchors { right: parent.right; rightMargin: 5; bottom: parent.bottom; bottomMargin: 3 }
                }
            }

            // add a click support to open task details in previous tab
            MouseArea {
                hoverEnabled: true
                anchors.fill: parent
                onExited: parent.opacity = 1.0
                onClicked: preview.requestId = modelData.id;
                onEntered: {
                    parent.opacity = 0.8
                    cursorShape = Qt.PointingHandCursor
                }
            }

            // Add a separator to list items
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: taskTitle.color; opacity: 0.2 }
        }
    }
} 
