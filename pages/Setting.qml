// Copyright (c) 2017-2018, The Edollar Project
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import QtQuick 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import QtQuick.Controls.Private 1.0


import "../../version.js" as Version


import "../components"
import edollarComponents.Clipboard 1.0


Flickable {
    id: settingPage
    visible: true
    enabled: true
    property string name: "Page Settings"
    property string title: qsTr("Settings")

    property int mWidth: appWindow.mWidth
    property int mHeight: appWindow.mHeight
    property int marginLeft: appWindow.mWidth/8
    property int marginTop: 20
    width: mWidth

    signal paymentClicked(string address, string amount, int mixinCount,
                          int priority, string description)
    signal sweepUnmixableClicked()

    property string startLinkText: qsTr("<style type='text/css'>a {text-decoration: none; color: #FF6C3C; font-size: 14px;}</style><font size='2'> (</font><a href='#'>Start daemon</a><font size='2'>)</font>") + translationManager.emptyString
    property bool showAdvanced: false

    property bool isWalletConnected: false
    property string passwordType: ''
    property var themeColorArray : ["#F44336", "#E91E63", "#9C27B0", "#673AB7", "#3F51B5", "#2196F3", "#03A9F4", "#00BCD4",
        "#009688", "#4CAF50", "#8BC34A", "#CDDC39", "#FFEB3B", "#FFC107", "#FF9800", "#FF5722", "#795548", "#9E9E9E", "#607D8B"]

    property bool useRemoteNode: false

    ColumnLayout {
        id: mainLayout
        anchors.margins: marginTop
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        spacing: 10

        //! Manage wallet
        RowLayout {
            Layout.fillWidth: true
            Text {
                id: manageWalletLabel
                color: "#222"
                text: qsTr("Manage wallet")
                Layout.topMargin: 10
                font.pixelSize: 16
                font.bold: true
            }
            Image {
                id: helpInfo
                width: 30
                height: 30
                Layout.leftMargin: 700//appWindow.width - 80
                fillMode: Image.PreserveAspectFit
                horizontalAlignment: Image.AlignRight
                verticalAlignment: Image.AlignTop
                source: "qrc:///images/tooltipInfoBlue.png"

                MouseArea {
                    id: helpInfoArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        helpInfoDialog.title = 'About'
                        helpInfoDialog.text = qsTr("You are using Edollar GUI Wallet version 0.1.0.0") +
                                    qsTr("\nIf you find any bugs or need improved features, Please report to github:") +
                                    qsTr("\n") +
                                    qsTr("https://github.com/edollar-project") +
                                    qsTr("\nFor more information, please visit our website https://edollar.cash Or contact us via email hello@edollar.cash") +
                                    qsTr("\n\nDonation:") +
                                    qsTr("\nAll donation will be used for further developement \n") +
                                    qsTr("\nBTC:1asjezMRSoWeVzx4bRQmGanudaEf2ntxz") +
                                    qsTr("\nXMR:49sDaUasWfZ3Ukjzwcwh52PzkEK7HA5TPeM469P7SaipeTmRQSdqvkB8NJNBrrJVMBTKNeryJ7PgvbowRvyFN7AGM1uN2wr")
                        helpInfoDialog.cancelVisible = false
                        helpInfoDialog.open()
                    }
                }
            }
        }
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#DEDEDE"
        }
        GridLayout {
            columns: 3
            StandardButton {
                id: changePasswordButton
                text: qsTr("Change password")
                Layout.leftMargin: 10
                width: 160
                onClicked: {
                    passwordType = 'change_password'
                    changePasswordDialog.open()
                }
            }

            StandardButton {
                id: showSeedAndKey
                text: qsTr("Show Seed and Keys")
                Layout.leftMargin: 50
                width: 160
                onClicked: {
                    passwordType = 'show_key'
                    changePasswordDialog.open()
                }
            }
        }


        //! Manage Daemon
        RowLayout {
            Layout.fillWidth: true
            Text {
                id: manageDaemonLabel
                Layout.preferredWidth: 200
                //Layout.fillWidth: true
                color: "#222"
                text: qsTr("Manage daemon")
                Layout.topMargin: 30
                Layout.bottomMargin: 5
                font.pixelSize: 16
                font.bold: true
            }
            Text {
                id: conectRemoteNodeLabel
                Layout.preferredWidth: 120
                color: "#222"
                text: qsTr("Use Remote Node")
                Layout.topMargin: 30
                Layout.bottomMargin: 5
                Layout.leftMargin: appWindow.mWidth - manageDaemonLabel.width - 250
                font.pixelSize: 14
                //font.bold: true
            }

            SwitchButton {
                id: toggleUseRemoteNode
                Layout.leftMargin:  10
                Layout.topMargin: 30
                onToggleChange: onSignalChange(on)
                width: 80
                height: 30
                on: useRemoteNode
            }

        }
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#DEDEDE"
        }
        GridLayout {
            visible: !useRemoteNode
            columns: 4
            LineEdit {
                id: daemonFlags
                Layout.preferredWidth:  360
                Layout.leftMargin: 10
                text: appWindow.persistentSettings.daemonFlags;
                placeholderText: qsTr("Daemon Flags (optional)")
            }
            StandardButton {
                id: addPeerButton
                text: qsTr("Add peer")
                Layout.leftMargin: 0
                width: 60
                onClicked: {
                    console.log('Add peer button clicked')
                    exclusiveWindow.show()
                }
            }
            StandardButton {
                id: startDaemonButton
                visible: !appWindow.daemonRunning
                text: qsTr("Start Daemon")
                Layout.leftMargin: 30
                width: 120
                onClicked: {
                    appWindow.startDaemon(daemonFlags.text)
                }
            }

            StandardButton {
                visible: appWindow.daemonRunning
                id: stopDaemonButton
                text: qsTr("Stop Daemon")
                Layout.leftMargin: 30
                width: 120
                onClicked: {
                    appWindow.stopDaemon()
                }
            }
            StandardButton {
                id: showDaemonStatus
                text: qsTr("Show Daemon Status")
                Layout.leftMargin: 30
                width: 120
                onClicked: {
                    daemonManager.sendCommand("status",currentWallet.testnet);
                    daemonConsolePopup.open();
                }
            }
        }

        //remote node
        GridLayout {
            visible: useRemoteNode
            columns: 4
            LineEdit {
                id: remoteUsername
                Layout.preferredWidth:  150
                Layout.leftMargin: 10
                text: appWindow.persistentSettings.daemonFlags;
                placeholderText: qsTr("Username")
            }
            LineEdit {
                id: remotePassword
                Layout.preferredWidth:  150
                Layout.leftMargin: 10
                text: appWindow.persistentSettings.daemonFlags;
                placeholderText: qsTr("Password")
            }
            LineEdit {
                id: remoteAddress
                Layout.preferredWidth:  360
                Layout.leftMargin: 10
                text: appWindow.persistentSettings.daemonFlags;
                placeholderText: qsTr("remote address (host:ip)")
            }
            StandardButton {
                id: remoteConnect
                text: appWindow.remoteNodeConnected? qsTr("Disconnect"): qsTr('Connect')
                Layout.leftMargin: 0
                width: 60
                onClicked: {
                    if (!appWindow.remoteNodeConnected) {
                        console.log('Connect to remote node')
                        appWindow.connectRemoteNode(remoteUsername.text, remotePassword.text, remoteAddress.text)
                    } else {
                        console.log('Disonnect from remote node')
                        appWindow.disconnectRemoteNode()
                    }

                }
            }
//            StandardButton {
//                id: showDaemonStatus
//                text: qsTr("Show Daemon Status")
//                Layout.leftMargin: 30
//                width: 120
//                onClicked: {
//                    daemonManager.sendCommand("status",currentWallet.testnet);
//                    daemonConsolePopup.open();
//                }
//            }
        }

        //! Manage Log
        RowLayout {
            Text {
                id: manageLogLabel
                Layout.fillWidth: true
                color: "#222"
                text: qsTr("Manage Log")
                Layout.topMargin: 30
                font.pixelSize: 16
                font.bold: true
            }
        }
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#DEDEDE"
        }

        RowLayout {
            z:1
            StandardDropdown {
              id: priorityDropdown
              width: 200
              Layout.leftMargin: 10
              currentIndex : appWindow.persistentSettings.logLevel
              z: 1
              dataModel: ListModel {
                  id: cbItems
                  ListElement { column1: "(0) - Default"; column2: "" }
                  ListElement { column1: "(1) - Warning Level"; column2: ""  }
                  ListElement { column1: "(2) - Info Level"; column2: "" }
                  ListElement { column1: "(3) - Debug Level"; column2: "" }
                  ListElement { column1: "(4) - Trace Level"; column2: "" }
              }
            }
            StandardButton {
                id: saveLogSetting
                text: qsTr("Save")
                shadowReleasedColor: appWindow.primaryColor
                shadowPressedColor: appWindow.primaryDarkColor
                releasedColor: appWindow.primaryColor
                pressedColor: appWindow.primaryDarkColor
                enabled: true
                Layout.leftMargin: 50
                width: 160
                z:1
                onClicked: {
                    appWindow.setLogLevel(priorityDropdown.currentIndex);
                }
            }
        }


        //! Manage Log
        RowLayout {
            Text {
                id: manageThemeLabel
                Layout.fillWidth: true
                color: "#222"
                text: qsTr("Manage theme")
                Layout.topMargin: 30
                font.pixelSize: 16
                font.bold: true
            }
        }
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#DEDEDE"
        }
        RowLayout {
            Layout.topMargin: 20
            Layout.leftMargin: 10
            TextInput {
                text: 'Default theme'
            }
            Rectangle {
                Layout.preferredWidth: 30
                Layout.preferredHeight: 30
                Layout.leftMargin: 20
                color: themeColorArray[4]
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        appWindow.switchPrimaryPalette(4)
                    }
                }
            }
        }

        GridLayout {
          id : themeCustomization
          Layout.topMargin: 10
          Repeater {
            id: themeColor
            Rectangle {
                Layout.preferredWidth: 30
                Layout.preferredHeight: 30
                Layout.leftMargin: 10
                color: themeColorArray[index]
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log('Onclick, index=', index)
                        appWindow.switchPrimaryPalette(index)
                        toggleUseRemoteNode.updateBackground()
                    }
                }
            }
         }
       }
    }

    SeedAndKeys {
        property var onCloseCallback
        id: seedAndKeysDialog
        cancelVisible: false
        onAccepted:  {
            if (onCloseCallback) {
                onCloseCallback()
            }
        }
    }

    PasswordDialog {
       id: changePasswordDialog
       onAccepted: {
           console.log('on accepted ', appWindow.walletPassword, changePasswordDialog.password)
           if(appWindow.walletPassword === changePasswordDialog.password){
               if (passwordType == 'change_password') newPasswordDialog.open()
               else if (passwordType == 'show_key') {
                    //doing something
                   if(appWindow.currentWallet.seedLanguage == "") {
                       console.log("No seed language set. Using English as default");
                       appWindow.currentWallet.setSeedLanguage("English");
                   }
                   seedAndKeysDialog.mnemonic = appWindow.currentWallet.seed
                   seedAndKeysDialog.spendKey = appWindow.currentWallet.secretSpendKey
                   seedAndKeysDialog.viewKey = appWindow.currentWallet.secretViewKey
                   seedAndKeysDialog.open()
               }

           } else {
               informationPopup.title  = qsTr("Error")
               informationPopup.text = qsTr("Wrong password");
               informationPopup.open()
               informationPopup.onCloseCallback = function() {
                   changePasswordDialog.open()
               }
           }
       }
       onRejected: {

       }
    }

    NewPasswordDialog {
        id: newPasswordDialog
        visible:false
        onAccepted: {
            if (appWindow.currentWallet.setPassword(newPasswordDialog.password)) {
                appWindow.walletPassword = newPasswordDialog.password;
                informationPopup.title = qsTr("Information") + translationManager.emptyString;
                informationPopup.text  = qsTr("Password changed successfully") + translationManager.emptyString;
                informationPopup.icon  = StandardIcon.Information;
            } else {
                informationPopup.title  = qsTr("Error") + translationManager.emptyString;
                informationPopup.text  = qsTr("Error: ") + currentWallet.errorString;
                informationPopup.icon  = StandardIcon.Critical;
            }
            informationPopup.onCloseCallback = null;
            informationPopup.open();
        }
        onRejected: {
        }
    }
    // Daemon console
    DaemonConsole {
        id: daemonConsolePopup
        height:500
        width:800
        title: qsTr("Daemon log") + translationManager.emptyString
        onAccepted: {
            close();
        }
    }

    AboutDialog {
        id: helpInfoDialog
        onAccepted: {
           close()
        }
    }

    ListModel {
         id: addressNodeModel
    }

    ExclusiveNodeWindow {
        id: exclusiveWindow
        model: addressNodeModel
    }

    // fires only once
    Component.onCompleted: {
        console.log('[Setting] component completed')
        appWindow.walletConnected.connect(onWalletConnected)
        appWindow.walletClosed.connect(onWalletClosed)
        if(typeof daemonManager != "undefined")
            daemonManager.daemonConsoleUpdated.connect(onDaemonConsoleUpdated)

        themeCustomization.rows = 1
        themeCustomization.columns = themeColorArray.length
        themeColor.model = themeColorArray.length

        var peers = appWindow.persistentSettings.peers
        var nodeAddress = peers.split(";")
        for (var i = 0; i < nodeAddress.length; ++i) {
            addressNodeModel.append({"nodeAddress": nodeAddress[i]})
        }


    }

    function updateSettings() {
        console.log('Update setting')
        var peers = "";
        for (var i = 0; i < addressNodeModel.count; ++i) {
            var nodeAddress = addressNodeModel.get(i).nodeAddress
            if (nodeAddress.length < 9) continue
            peers += nodeAddress
            if (i != addressNodeModel.count - 1) peers += ';'
        }
        console.log('settings peers: ', peers)
        appWindow.persistentSettings.peers = peers
    }

    function deleteExclusiveNode(index) {
        addressNodeModel.remove(index)
        updateSettings()
    }

    function addExclusiveNode(nodeAddress) {
        addressNodeModel.append({'nodeAddress': nodeAddress})
        updateSettings()
    }

    function onSignalChange(connectRemote) {
        if (connectRemote) {
            appWindow.persistentSettings.useRemoteNode = true
            remoteAddress.text = appWindow.persistentSettings.remoteAddress
            useRemoteNode = true
        }
        else {
            useRemoteNode = false
            appWindow.persistentSettings.useRemoteNode = false
        }
        console.log('remote:',appWindow.persistentSettings.useRemoteNode)
    }

    function onDaemonConsoleUpdated(message) {
        // Update daemon console
        daemonConsolePopup.textArea.append(message)
    }

    function onWalletConnected() {
        console.log('[Settings] on wallet connected')
        isWalletConnected = true
        useRemoteNode = appWindow.persistentSettings.useRemoteNode
        toggleUseRemoteNode.on = useRemoteNode
        console.log('useRemoteNode ', useRemoteNode)
        toggleUseRemoteNode.changeStatus(useRemoteNode)
        if (useRemoteNode && appWindow.persistentSettings.remoteAddress) {
            remoteUsername.text = appWindow.persistentSettings.remoteUserName
            remotePassword.text = appWindow.persistentSettings.remotePassword
            remoteAddress.text = appWindow.persistentSettings.remoteAddress
        }
    }

    function onWalletClosed() {
        console.log('[Settings] on wallet close')
    }
}




