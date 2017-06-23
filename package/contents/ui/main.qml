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
import QtQuick.Dialogs 1.1
import Qt.labs.settings 1.0
import QtQuick.Controls 2.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
    id: rootItem
    width: 450; height: 350
    implicitWidth: width; implicitHeight: height
    Layout.minimumWidth: width; Layout.minimumHeight: height

    // to request tasks assigned to user, we needs the user id
    // this function load the user id using the user email, phabricator token and phabricator url
    function loadUserId() {
        jsonModel.requestParams = "api.token=%1&emails[0]=%2".arg(settings.token).arg(settings.useremail);
        jsonModel.source += "/api/user.query";
        messageBar.show(qsTr("Loading your phabricator id..."));
        jsonModel.load(function(response) {
            if (response && jsonModel.httpStatus == 200) {
                settings.userPhabricatorId = response.result[0].phid
                messageBar.show(qsTr("Your id was success loaded!"))
                maniphestPage.maniphestPageRequest()
            }
        });
    }

    // the storage of widget data (token, user id and phabricator url)
    Settings {
        id: settings
        objectName: "Phabricator Widget"
        property string token
        property string phabricatorUrl
        property string useremail
        property string userPhabricatorId

        Component.onCompleted: {
            Plasmoid.fullRepresentation = column;
            if (settings.token && settings.userPhabricatorId)
                maniphestPage.maniphestPageRequest();
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

    // show in widget bottom dynamically messages
    MessageBar {
        id: messageBar
        z: tabGroup.z + 10
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
}
