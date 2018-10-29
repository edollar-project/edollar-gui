import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0
import "../common"
import QtQuick.Dialogs 1.2

import "../components"
import edollarComponents.Clipboard 1.0
import edollarComponents.Wallet 1.0
import edollarComponents.WalletManager 1.0
import edollarComponents.TransactionHistory 1.0
import edollarComponents.TransactionHistoryModel 1.0

import QtQuick.Window 2.2
import QtQuick.Controls.Styles 1.4

Flickable {
    id: flickable
    property string name: "PageThree"
    property string title: qsTr("Receive")

    property int mWidth: Screen.desktopAvailableWidth
    property int mHeight: Screen.desktopAvailableHeight
    property int marginLeft: mWidth/8

    Item {
        id: pageThreeRect
        //color: "#F0EEEE"
        width: mWidth

        property alias addressText : addressLine.text
        property var model
        property string statusLabel: ""

        function makeQRCodeString() {
            return addressLine.text
        }

        function setTrackingLineText(text) {
            // don't replace with same text, it wrecks selection while the user is selecting
            // also keep track of text, because when we read back the text from the widget,
            // we do not get what we put it, but some extra HTML stuff on top
            if (text != statusLabel.text) {
                statusLabel.text = text
            }
        }

        function update() {
            if (!appWindow.currentWallet) {
                setTrackingLineText("-")
                return
            }
            if (appWindow.currentWallet.connected() == Wallet.ConnectionStatus_Disconnected) {
                setTrackingLineText(qsTr("WARNING: no connection to daemon"))
                return
            }
        }

        Clipboard { id: clipboard }

        //TODO: change this to layout and responsive
        Label {
            id: addressLabel
            fontSize: 14
            text: qsTr("Main Address")
            x: marginLeft
            anchors.top: parent.top
            anchors.topMargin: 40
        }
        LineEdit {
            id: addressLine
            fontSize: 14
            placeholderText: qsTr("ReadOnly wallet address displayed here")
            readOnly: true
            width: 6*marginLeft
            x: marginLeft
            anchors.top: addressLabel.bottom
            anchors.topMargin: 5
            onTextChanged: cursorPosition = 0

            IconButton {
                imageSource: "../images/copyToClipboard.png"
                onClicked: {
                    if (addressLine.text.length > 0) {
                        console.log(addressLine.text + " copied to clipboard")
                        clipboard.setText(addressLine.text)
                    }
                }
            }
        }

        //Generat sub address
        Label {
            id: subAddressLabel
            fontSize: 14
            text: qsTr("Main Address")
            x: marginLeft
            anchors.top: addressLine.bottom
            anchors.topMargin: 20
        }
        LineEdit {
            id: subAddressLine
            fontSize: 14
            placeholderText: qsTr("ReadOnly wallet address displayed here")
            readOnly: true
            width: 5*marginLeft + marginLeft/2 - 10
            x: marginLeft
            anchors.top: subAddressLabel.bottom
            anchors.topMargin: 5
            onTextChanged: cursorPosition = 0

            IconButton {
                imageSource: "../images/copyToClipboard.png"
                onClicked: {
                    if (addressLine.text.length > 0) {
                        console.log(addressLine.text + " copied to clipboard")
                        clipboard.setText(addressLine.text)
                    }
                }
            }
        }
        StandardButton {
            id: generateSunAddressButton
            anchors.top: subAddressLabel.bottom
            anchors.topMargin: 5
            x: marginLeft + subAddressLine.width + 10
            width: marginLeft/2
            text: qsTr("Generate")
            shadowReleasedColor: "#3F51B5"
            shadowPressedColor: "#303F9F"
            releasedColor: "#3F51B5"
            pressedColor: "#303F9F"
            enabled : true
            onClicked: {
                qrCode.source = "image://qrcode/" + "123"
            }
        }

        //status info
        Label {
            id: statusLabel
            fontSize: 14
            text: "Status"
            anchors.top: generateSunAddressButton.bottom
            anchors.topMargin: 20
            width: 2*marginLeft
            x: 2*marginLeft
        }

        MessageDialog {
            id: trackingHowToUseDialog
            standardButtons: StandardButton.Ok
        }

        FileDialog {
            id: qrFileDialog
            title: "Please choose a name"
            folder: shortcuts.pictures
            selectExisting: false
            nameFilters: [ "Image (*.png)"]
            onAccepted: {
                if( ! walletManager.saveQrCode(makeQRCodeString(), walletManager.urlToLocalPath(fileUrl))) {
                    console.log("Failed to save QrCode to file " + walletManager.urlToLocalPath(fileUrl) )
                    trackingHowToUseDialog.title  = qsTr("Save QrCode") + translationManager.emptyString;
                    trackingHowToUseDialog.text = qsTr("Failed to save QrCode to ") + walletManager.urlToLocalPath(fileUrl) + translationManager.emptyString;
                    trackingHowToUseDialog.icon = StandardIcon.Error
                    trackingHowToUseDialog.open()
                }
            }
        }

        Menu {
            id: qrMenu
            title: "QrCode"
            MenuItem {
               text: qsTr("Save As") + translationManager.emptyString;
               onTriggered: qrFileDialog.open()
            }
        }

        Image {
            id: qrCode
            anchors.top: subAddressLine.bottom
            anchors.topMargin: 100
            //Layout.fillWidth: true
            //Layout.minimumHeight: mHeight/3
            width: 200
            height: 200
            x: mWidth/2 - qrCode.width/2
            smooth: false
            fillMode: Image.PreserveAspectFit
            source: "image://qrcode/" + pageThreeRect.makeQRCodeString()
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                onClicked: {
                    if (mouse.button == Qt.RightButton)
                        qrMenu.popup()
                }
                onPressAndHold: qrFileDialog.open()
            }
        }

        Timer {
            id: timer
            interval: 2000; running: false; repeat: true
            onTriggered: update()
        }

        function onPageCompleted() {
            console.log("Receive page loaded ...");

            if (appWindow.currentWallet) {
                console.log("Wallet address: " + appWindow.currentWallet.address)
                if (addressLine.text.length === 0 || addressLine.text !== appWindow.currentWallet.address) {
                    addressLine.text = appWindow.currentWallet.address
                }
            } else {
                console.log("current wallet is null")
            }

            update()
            timer.running = true
        }

        function onPageClosed() {
            timer.running = false
        }
    }

    Component.onCompleted: {
        console.log("======Compoment comleted=======")
        pageThreeRect.onPageCompleted()
    }




} // flickable

