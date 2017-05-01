import Qt.labs.platform 1.0

SystemTrayIcon {
    visible: true
    iconSource: "../images/warning.svg"
    onMessageClicked: console.log("Message clicked")
}
