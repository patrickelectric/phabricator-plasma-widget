/***************************************************************************
 *   Copyright (C) 2017 by Enoque Joseneas <enoquejoseneas@gmail.com>                            *
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

Item {
    width: 200; height: 200
    
    //PlasmaCore.IconSize.Horizontal: 200
    //PlasmaCore.IconSize.Horizontal: 200
    function setVisibleItem() {
        if (!settings.token.length) 
            Plasmoid.fullRepresentation = column
        else
            Plasmoid.fullRepresentation = listview
    }
        
    Component.onCompleted: {
        //jsonModel.load()
        setVisibleItem()
    }
    
    Settings {
        id: settings
        property string token
        property url phabricatorUrl
    }
    
     
    ColumnLayout {
        id: column
        spacing: 10
        width: parent.width
        height: parent.height
        
        Label{
            text: "Enter the token:"
        }
        TextField {
            id: tokenfield
            width: parent.width; height: 25
        }
        Label{
            text: "Enter the Phabricator URL:"
        }
        TextField {
            id: phabricatorUrlfield
            width: parent.width; height: 25
        }
        Button {
            id: button
            text: "Submit"
            anchors{
                right: parent.right
                rightMargin: 5
            }
            onClicked: {
                if (tokenfield.text && phabricatorUrlfield.text){
                    settings.token = tokenfield.text
                    settings.phabricatorUrl = phabricatorUrlfield.text
                    jsonModel.load()
                }
            }
        }
    }
    
    Connections {
        target: jsonModel
        onJsonChanged: {
            console.log(jsonModel.httpStatus)
            if (jsonModel.httpStatus == 200){
                setVisibleItem()
                column.visible = false
            }
        }
    }
    
    ListView {
        id: listview
        anchors.fill: parent
        clip: true
        visible: !column.visible
        model: jsonModel.json.result.data
        delegate: ItemDelegate {
            text: modelData.fields.name
        }
    }
    JSONListModel {
        id: jsonModel
        source: "https://phabricator.ifba.edu.br/api/maniphest.search"
        requestMethod: "POST"
    }

}
