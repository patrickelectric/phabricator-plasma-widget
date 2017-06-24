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

    function loadUserId() {
        jsonModel.requestParams = "api.token=%1&emails[0]=%2".arg(settings.token).arg(settings.useremail);
        jsonModel.source += "user.query";
        jsonModel.load(function(response) {
            if (response && jsonModel.httpStatus == 200) {
                settings.userPhabricatorId = response.result[0].phid
                maniphestPage.maniphestPageRequest()
            }
        });
    }

    function setProjectsModel() {
        if (typeof settings.projectList == "undefined" || !settings.projectList.length)
            return;
        if (comboBoxProjectsModel.count)
            comboBoxProjectsModel.clear();
        var objc = {}, project = {};
        for (var i = 0; i < settings.projectList.length; i++) {
            project = settings.projectList[i];
            if (project.type !== "PROJ")
                continue;
            objc = ({"id": project.phid, "name": project.fields.name});
            comboBoxProjectsModel.append(objc);
        }
        comboBoxProjects.setIndex();
    }

    function loadProjects() {
        jsonModel.requestParams = "api.token=%1".arg(settings.token);
        jsonModel.source += "project.search";
        jsonModel.load(function(response) {
            if (jsonModel.httpStatus == 200 && response.result && response.result.data.length > 0) {
                var fixBindArray = response.result.data;
                settings.projectList = fixBindArray;
                setProjectsModel();
            }
        });
    }

    Connections {
        target: settings
        onReady: setProjectsModel()
        onProjectIdChanged: {
            if (typeof settings.projectList != "undefined" && !settings.projectList.length) {
                loadProjects();
            } else if (!settings.projectId) {
                var fixBindArray = [];
                settings.projectList = fixBindArray;
            }
        }
    }

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

            Column {
                spacing: 5; width: parent.width
                anchors { left: parent.left; right: parent.right; margins: 15 }

                PlasmaComponents.Label {
                    text: qsTr("Choose a option to filter tasks and reviews:")
                }

                Row {
                    spacing: 5; width: parent.width
 
                    PlasmaComponents.CheckBox {
                        id: assignedForUserBtn
                        text: qsTr("Assigned for you")
                        onCheckedChanged: {
                            if (checked) {
                                var str = "";
                                settings.projectId = str;
                                specificProjectBtn.checked = false;
                            }
                        }
                     
                        Component.onCompleted: checked = (settings.projectId === "")
                    }

                    PlasmaComponents.CheckBox {
                        id: specificProjectBtn
                        text: qsTr("From specific project")
                        onCheckedChanged: {
                            if (checked) {
                                assignedForUserBtn.checked = false;
                                loadProjects();
                            }
                        }

                        Component.onCompleted: checked = (settings.projectId !== "")
                    }
                }

                PlasmaComponents.Label {
                    visible: specificProjectBtn.checked
                    text: qsTr("Select the project:")
                }

                PlasmaComponents.ComboBox {
                    id: comboBoxProjects
                    width: parent.width
                    textRole: "name"
                    visible: specificProjectBtn.checked
                    model: ListModel { id: comboBoxProjectsModel }
                    onActivated: {
                        var project = comboBoxProjectsModel.get(index);
                        settings.projectId = project.id;
                    }

                    function setIndex() {
                        var objc = ({});
                        for (var i = 0; i < comboBoxProjectsModel.count; ++i) {
                            objc = comboBoxProjectsModel.get(i);
                            if (settings.projectId === objc.id) {
                                comboBoxProjects.currentIndex = i;
                                return;
                            }
                        }
                        comboBoxProjects.currentIndex = -1;
                    }
                }
            }

            PlasmaComponents.Label {
                id: phabricatorUserId
                visible: settings.userPhabricatorId.length > 0; opacity: 0.7
                text: settings.userPhabricatorId ? qsTr("Your phabricator ID is ") + settings.userPhabricatorId : ""
                anchors.horizontalCenter: parent.horizontalCenter
            }

            PlasmaComponents.Button {
                id: button
                text: qsTr("Submit")
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    if (useremailField.text && tokenField.text && phabricatorUrlField.text) {
                        settings.token = tokenField.text.trim();
                        settings.useremail = useremailField.text.toLowerCase().trim();
                        settings.phabricatorUrl = phabricatorUrlField.text.trim();
                        if (settings.phabricatorUrl.indexOf("/api") < 0)
                            settings.phabricatorUrl += "/api/";
                        loadUserId();
                    }
                }
            }

            Item { width: parent.width; height: 25 }
        }
    }
}
