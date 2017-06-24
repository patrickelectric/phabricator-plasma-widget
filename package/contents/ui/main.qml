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
import Qt.labs.settings 1.0
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
    id: rootItem
    Plasmoid.title: qsTr("Phabricator Widget")
    width: 450; height: 350
    implicitWidth: width; implicitHeight: height
    Layout.minimumWidth: width; Layout.minimumHeight: height


    // the widget persistence data (token, user id and phabricator url)
    Settings {
        id: settings
        objectName: "Phabricator Widget"

        property string phabricatorUrl
        property string projectId
        property var projectList
        property string token
        property string useremail
        property string userPhabricatorId

        signal ready()

        Component.onCompleted: {
            Plasmoid.fullRepresentation = column
            if (!token || !useremail || !phabricatorUrl) {
                tabGroup.currentTab = settingsPage;
                tabBar.currentTab = settingsPageButton;
            } else {
                ready()
            }
        }
    }

    // the request http object
    JSONListModel {
        id: jsonModel
        source: settings.phabricatorUrl
        requestMethod: "POST"
        // reset url after each request response
        onStateChanged: if (state === "ready" || state === "error") jsonModel.source = settings.phabricatorUrl
    }

    // show system notification for new events
    Notification {
        id: systemTrayNotification
    }

    Column {
        id: column
        spacing: 2; width: parent.width; anchors.fill: parent

        Row {
            width: parent.width; height: tabBar.height

            PlasmaComponents.TabBar {
                id: tabBar
                z: parent.z + 100; clip: true; width: parent.width

                PlasmaComponents.TabButton {
                    tab: maniphestPage
                    text: qsTr("Maniphest")
                    clip: true
                }

                PlasmaComponents.TabButton {
                    id: settingsPageButton
                    tab: settingsPage
                    text: qsTr("Settings")
                    clip: true
                }

                PlasmaComponents.TabButton {
                    tab: aboutPhabricatorPage
                    text: qsTr("About Phabricator")
                    clip: true
                }
            }
        }

        PlasmaComponents.TabGroup {
            id: tabGroup
            clip: true
            width: parent.width; height: parent.height - tabBar.height

            ManiphestPage {
                id: maniphestPage
            }

            SettingsPage {
                id: settingsPage
            }

            AboutPhabricatorPage {
                id: aboutPhabricatorPage
            }
        }
    }

    PlasmaComponents.BusyIndicator {
        width: 32; height: width
        visible: jsonModel.state === "loading"
        anchors { bottom: parent.bottom; right: parent.right; margins: 5 }
    }
}
