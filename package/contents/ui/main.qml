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
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import Qt.labs.settings 1.0
import QtQuick.Dialogs 1.1

Item {
    width: 400; height: 350
    implicitWidth: width; implicitHeight: height
    Layout.minimumWidth: width; Layout.minimumHeight: height

    MessageDialog {
        id: dialog
        title: qsTr("Warning!")

        function show(message) {
            dialog.text = message;
            dialog.open();
        }
    }

    BusyIndicator {
        visible: jsonModel.state == "loading"
        anchors.centerIn: parent
    }
    
    Timer {
        interval: 500; running: true; repeat: true
        onTriggered: maniphestPage.maniphestPageRequest()
    }
    
    Settings {
        id: settings
        property string token
        property string phabricatorUrl

        Component.onCompleted: {
            Plasmoid.fullRepresentation = column;
            if (settings.token)
                maniphestPage.maniphestPageRequest();
        }
    }

    JSONListModel {
        id: jsonModel
        source: settings.phabricatorUrl
        requestMethod: "POST"
        onJsonChanged: jsonModel.source = settings.phabricatorUrl;
    }

    Column {
        id: column
        spacing: 0
        width: parent.width
        anchors.fill: parent
        
        PlasmaComponents.TabBar {
            id: tabBar
            z: parent.z + 100; clip: true; width: parent.width

            PlasmaComponents.TabButton {
                tab: maniphestPage
                text: qsTr("Maniphest")
                clip: true
            }
            
            PlasmaComponents.TabButton {
                id: previewPageButton
                tab: previewPage
                text: qsTr("Preview")
                clip: true
            }
            
            PlasmaComponents.TabButton {
                tab: settingsPage
                text: qsTr("Settings")
                clip: true
            }
        }

         PlasmaComponents.TabGroup {
            id: tabGroup
            clip: true
            width: parent.width; height: parent.height - tabBar.height - anchors.topMargin

            PlasmaComponents.Page {
                id: maniphestPage
                anchors.fill: parent

                property var maniphestData

                Connections {
                    target: jsonModel
                    onJsonChanged: {
                        console.log(JSON.stringify(jsonModel.json))
                        if (jsonModel.httpStatus == 200 /*&& maniphestView.count == 0*/)
                            maniphestPage.maniphestData = jsonModel.json.result.data;
                    }
                }

                function maniphestPageRequest() {
                    jsonModel.requestParams = "api.token="+settings.token+"&constraints[assigned][0]=PHID-USER-47myrwgl5rbntutgxn2o"
                    jsonModel.source += "/api/maniphest.search";
                    jsonModel.load();
                }

                ListView {
                    id: maniphestView
                    anchors.fill: parent
                    implicitWidth: 300
                    implicitHeight: implicitWidth / 2
                    Layout.minimumWidth: 300
                    Layout.minimumHeight: 300
                    clip: true
                    model: maniphestPage.maniphestData
                    delegate: Rectangle {
                        color: "#fff"
                        width: maniphestView.width; height: 45
                        PlasmaComponents.Label {
                            id: textName
                            width: parent.width*0.90
                            elide: Text.ElideRight
                            text: modelData.fields.name
                            anchors {
                                left: parent.left
                                leftMargin: 10
                                verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            hoverEnabled: true
                            anchors.fill: parent
                            onEntered: cursorShape = Qt.PointingHandCursor
                            onClicked: { 
                                previewPage.requestId = modelData.id;
                                previewPageButton.clicked();
                            }
                        }

                        Rectangle { width: parent.width; height: 1; color: textName.color }
                    }
                }
            }

            PlasmaComponents.Page {
                id: previewPage
                anchors.fill: parent

                property int requestId: 0

                onRequestIdChanged: {
                    jsonModel.requestParams = "api.token=%1&constraints[ids][0]=%2".arg(settings.token).arg(requestId);
                    jsonModel.source += "/api/maniphest.search";
                    jsonModel.load();
                }

                Column {
                    spacing: 10

                    Text {
                        text: typeof jsonModel.json.result !== "undefined" ? jsonModel.json.result.data[0].fields.name : ""
                    }

                    Text {
                        text: typeof jsonModel.json.result !== "undefined" ? jsonModel.json.result.data[0].fields.description.raw : ""
                    }
                }
            }

            PlasmaComponents.Page {
                id: settingsPage
                anchors.fill: parent

                ColumnLayout {
                    spacing: 4
                    width: parent.width; height: parent.height
                    anchors.horizontalCenter: parent.horizontalCenter

                    PlasmaComponents.Label {
                        text: qsTr("Enter the token:")
                    }

                    PlasmaComponents.TextField {
                        id: tokenfield
                        width: parent.width; height: 20
                        text: settings.token
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    PlasmaComponents.Label {
                        text: qsTr("Enter the Phabricator URL:")
                    }

                    PlasmaComponents.TextField {
                        id: phabricatorUrlfield
                        width: parent.width; height: 20
                        text: settings.phabricatorUrl
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    PlasmaComponents.Button {
                        id: button
                        text: qsTr("Submit")
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked: {
                            if (tokenfield.text && phabricatorUrlfield.text) {
                                settings.token = tokenfield.text;
                                settings.phabricatorUrl = phabricatorUrlfield.text;
                                maniphestPage.maniphestPageRequest();
                            }
                        }
                    }
                }
            }
        }
    }
}
