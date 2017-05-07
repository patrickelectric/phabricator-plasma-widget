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

import QtQuick 2.8

Item {
    id: rootItem
    state: "null"
    states: [
          State { name: "null" },
          State { name: "ready" },
          State { name: "loading" },
          State { name: "error" }
    ]

    property string source: ""
    property string requestParams
    property string errorString: ""
    property string requestMethod: "GET"
    property string requestHeader: "application/x-www-form-urlencoded"
    property int httpStatus: 0
    property var json

    function load(callback) {
        var xhr = new XMLHttpRequest
        xhr.open(requestMethod, (requestMethod === "GET") ? source + "?" + requestParams : source);
        xhr.setRequestHeader('Content-type', requestHeader);
        xhr.onerror = function() {
            rootItem.errorString = qsTr("Cannot connect to server!");
            rootItem.state = "error";
        }
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                rootItem.httpStatus = xhr.status
                if (rootItem.httpStatus >= 200 && rootItem.httpStatus <= 299) {
                    rootItem.state = "ready"
                    if (callback)
                        callback(xhr.responseText.length ? JSON.parse(xhr.responseText) : {})
                    else
                        json = xhr.responseText.length ? JSON.parse(xhr.responseText) : {}
                } else {
                    rootItem.errorString = qsTr("The server returned error ") + xhr.status
                    rootItem.state = "error"
                }
            }
        }
        rootItem.errorString = ""
        rootItem.state = "loading"
        json = undefined
        xhr.send(requestParams); // requestParams ignored if requestMethod is GET
    }
}
