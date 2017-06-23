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

import QtQuick 2.6
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1
import org.kde.plasma.components 2.0 as PlasmaComponents

PlasmaComponents.Page {
    clip: true; anchors.fill: parent

    Component.onCompleted: console.log("About Phabricator page loaded!")

    Item {
        id: rectangle
        width: parent.width* 0.80; height: label.implicitHeight
        anchors.centerIn: parent

        PlasmaComponents.Label {
            width: parent.width
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignJustify
            wrapMode: Label.Wrap
            textFormat: Text.RichText
            onLinkActivated: Qt.openUrlExternally(link)
            text: qsTr("Phabricator is a complete set of tools for developing software. Included apps help you manage tasks and sprints, review code, host git, svn, or mercurial repositories, build with continuous integration, review designs, discuss in internal chat channels, and much more. It's fast, scalable, and fully open source. Install it locally with no limitations, or have us host it for you. Read more about <a href=\"https://www.phacility.com/phabricator/\">Phabricator</a>")
        }
    }
}
