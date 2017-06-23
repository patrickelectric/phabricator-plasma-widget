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
import org.kde.plasma.components 2.0 as PlasmaComponents

PlasmaComponents.Page {
    id: settingsPage
    clip: true; anchors.fill: parent

    Component.onCompleted: console.log("Settings page loaded!")

    Flickable {
        anchors.fill: parent; height: rootItem.height
        contentHeight: formColumn.implicitHeight
        ScrollBar.vertical: ScrollBar { }

        ColumnLayout {
            id: formColumn
            spacing: 10; anchors.fill: parent

            PlasmaComponents.Label {
                text: qsTr("Enter you phabricator email:")
                anchors {left: parent.left; leftMargin: 15; bottom: useremailField.top; bottomMargin: 5 }
            }

            PlasmaComponents.TextField {
                id: useremailField
                text: settings.useremail
                anchors { left: parent.left; right: parent.right; margins: 15 }
            }

            PlasmaComponents.Label {
                text: qsTr("Enter the phabricator conduit token:")
                anchors {left: parent.left; leftMargin: 15; bottom: tokenField.top; bottomMargin: 5 }
            }

            PlasmaComponents.TextField {
                id: tokenField
                text: settings.token
                anchors { left: parent.left; right: parent.right; margins: 15 }
            }

            PlasmaComponents.Label {
                text: qsTr("Enter the phabricator url:")
                anchors {left: parent.left; leftMargin: 15; bottom: phabricatorUrlField.top; bottomMargin: 5 }
            }

            PlasmaComponents.TextField {
                id: phabricatorUrlField
                text: settings.phabricatorUrl
                anchors { left: parent.left; right: parent.right; margins: 15 }
            }

            PlasmaComponents.Label {
                id: phabricatorUserId
                visible: settings.userPhabricatorId.length > 0
                text: qsTr("Your phabricator ID is ") + settings.userPhabricatorId
                anchors.horizontalCenter: parent.horizontalCenter
            }

            PlasmaComponents.Button {
                id: button
                text: qsTr("Submit")
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    if (useremailField.text && tokenField.text && phabricatorUrlField.text) {
                        settings.token = tokenField.text;
                        settings.useremail = useremailField.text;
                        settings.phabricatorUrl = phabricatorUrlField.text;
                        loadUserId();
                    } else {
                        messageBar.show(qsTr("All fields needs to be set!"));
                    }
                }
            }

            Item { width: parent.width; height: 25 }
        }
    }
}
