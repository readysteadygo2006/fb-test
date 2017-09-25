import VPlayApps 1.0
import VPlayPlugins 1.0
import QtQuick 2.0
import QtWebSockets 1.0
import QtWebSockets 1.0

import "helper"
import "pages"

/*/////////////////////////////////////
  NOTE:
  Additional integration steps are needed to use V-Play Plugins, for example to add and link required libraries for Android and iOS.
  Please follow the integration steps described in the plugin documentation of your chosen plugins:
  - Firebase: https://v-play.net/doc/plugin-firebase/

  To open the documentation of a plugin item in Qt Creator, place your cursor on the item in your QML code and press F1.
  This allows to view the properties, methods and signals of V-Play Plugins directly in Qt Creator.

/////////////////////////////////////*/

App {
    // You get free licenseKeys from http://v-play.net/licenseKey
    // With a licenseKey you can:
    //  * Publish your games & apps for the app stores
    //  * Remove the V-Play Splash Screen or set a custom one (available with the Pro Licenses)
    //  * Add plugins to monetize, analyze & improve your apps (available with the Pro Licenses)
    //licenseKey: "<generate one from http://v-play.net/licenseKey>"

    licenseKey: "B6181157092D8FF14720DDD7797A6A66B7C83A6890F8453FF7C94A42BF78C92D6A4B5A467F77B7D8EFB68966FD580D9894F75600ABEC8B28D1FEC509F1248FAE7CDCCC579B33C7DED871A77CD184A86371D9AB1BEFE6689A24B5BB11BE84BE19EBD8BD4041B0CF2A7B7CB82222C54B6F624BC6329DF853CE9A93594251B9587C6F612FAFF4D0511B3ACBEE178DAFFFD0DA7253CF4BCDD43E2A6B4A7B1F209AB09B06308C1DD03018C8C2F011B138883BF48A76BCB4803E918EF83D5774488D33291A0A131A02BE27418C6BAD57B0E65C67DE06F10A4EEFE1B3B2BF6873151934FEB78A64AA568FFCC474ADBCFC70869F23EE92FB538AA4187A29C562214BDB3FACCF27A09A2B50D36260D45C41DBBD3870C49ECC25323BE135DBF30C05104E01AA66206AF666B6D245A2EA77368F5CEB26C07DDD22929897BE18BE44FA353EC201D70D590DCC91C63F257BA8A05762A5D596A5379E97A66790D12049FF29AB29"

    // This project contains sample integrations of all selected plugins
    // To use and configure the plugins, please have a look at
    // - Plugin Integration guide of used plugins (https://v-play.net/plugins)
    // - The plugin configuration properties in Constants.qml (qml/common folder)
    // - The plugin QML pages in this project (qml/pages folder)
    // NOTE: Some plugins items within the pages are commented in the QML code, as they require more configuration to be runnable / testable

    property alias firebasePage: firebasePage


    Rectangle {
        width: 360
        height: 360

        WebSocket {
            id: socket
            url: "ws://192.168.1.110:8000"
            onTextMessageReceived: {
                messageBox.text = messageBox.text + "\nReceived message: " + message
            }
            onStatusChanged: if (socket.status == WebSocket.Error) {
                                 console.log("Error: " + socket.errorString)
                             } else if (socket.status == WebSocket.Open) {
                                 socket.sendTextMessage("Hello World")
                             } else if (socket.status == WebSocket.Closed) {
                                 messageBox.text += "\nSocket closed"
                             }
            active: false
        }

        WebSocket {
            id: secureWebSocket
            url: "wss://echo.websocket.org"
            onTextMessageReceived: {
                messageBox.text = messageBox.text + "\nReceived secure message: " + message
            }
            onStatusChanged: if (secureWebSocket.status == WebSocket.Error) {
                                 console.log("Error: " + secureWebSocket.errorString)
                             } else if (secureWebSocket.status == WebSocket.Open) {
                                 secureWebSocket.sendTextMessage("Hello Secure World")
                             } else if (secureWebSocket.status == WebSocket.Closed) {
                                 messageBox.text += "\nSecure socket closed"
                             }
            active: false
        }
        Text {
            id: messageBox
            text: socket.status == WebSocket.Open ? qsTr("Sending...") : qsTr("Welcome!")
            anchors.centerIn: parent
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                socket.active = !socket.active
                secureWebSocket.active =  !secureWebSocket.active;
                //Qt.quit();
            }
        }
    }

    FirebasePage {
        id: firebasePage
        visible: false
        onPopped:  { firebasePage.parent = pluginMainItem; visible = false }
    }

    // app content with plugin list
    NavigationStack {
        id: pluginMainItem

        // initial page contains list if plugins and opens pages for each plugin when selected
        ListPage {
            id: page
            title: qsTr("V-Play Plugins")

            model: ListModel {
                ListElement { type: "Database & Authentication"; name: "Firebase"
                    detailText: "Manage users and use Realtime Database"; image: "../assets/logo-firebase.png" }
            }

            delegate: PluginListItem {
                visible: name !== "GameCenter" || Theme.isIos

                onSelected: {
                    switch (name) {
                    case "Firebase":
                        page.navigationStack.push(firebasePage)
                        break
                    }
                }
            }

            section.property: "type"
            section.delegate: SimpleSection { }
        }
    }
}
