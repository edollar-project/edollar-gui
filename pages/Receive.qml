import QtQuick 2.2
import QtQuick.Layouts 1.1
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
import edollarComponents.Subaddress 1.0
import edollarComponents.SubaddressModel 1.0

import QtQuick.Window 2.2
import QtQuick.Controls.Styles 1.2

Flickable {
    id: pageReceive
    property string name: "Page Receive"
    property string title: qsTr("Receive")

    property var current_address
    property alias addressText : pageReceive.current_address

    property int mWidth: appWindow.mWidth
    property int mHeight: appWindow.mHeight
    property int marginLeft: appWindow.mWidth/10
    property int marginTop: 20

    property bool isNewAddress: true

    width: mWidth

    Item {
        id: pageReceiveRect
        //color: "#F0EEEE"
        width: mWidth

        //property alias addressText : addressLine.text
        property var model
        property string statusLabel: ""

        function makeQRCodeString() {
            return current_address
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

        ColumnLayout {
            id: addressRow
            Text {
                id: addressLabel
                text: qsTr("Addresses")
                font.family: "Arial"
                font.pixelSize: 14
                color: '#003399'
                Layout.leftMargin: marginLeft
                Layout.topMargin: marginTop
            }

            Rectangle {
                id: tableRect
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                Layout.leftMargin: marginLeft
                color: "#FFFFFF"
                width: 8*marginLeft
                //x: marginLeft
                Scroll {
                    id: flickableScroll
                    anchors.right: table.right
                    anchors.top: table.top
                    anchors.bottom: table.bottom
                    flickable: table
                }
                SubaddressTable {
                    id: table
                    width: 8*marginLeft
                    x: marginLeft
                    anchors.fill: parent
                    onContentYChanged: flickableScroll.flickableContentYChanged()
                    onCurrentItemChanged: {
                        current_address = appWindow.currentWallet.address(appWindow.currentWallet.currentSubaddressAccount, table.currentIndex);
                    }
                }
            }

            RowLayout {
                spacing: 20
                Layout.topMargin: marginTop
                Layout.leftMargin: 3.5*marginLeft
                StandardButton {
                    text: qsTr("Create new address") + translationManager.emptyString;
                    enabled: appWindow.currentWallet && !appWindow.currentWallet.viewOnly
                    onClicked: {
                        isNewAddress = true
                        texIntputDialog.labelTitle = qsTr("Set the label of the new address:")
                        //texIntputDialog.text = qsTr("(Untitled)")
                        texIntputDialog.open()
                    }
                }
                StandardButton {
                    enabled: table.currentIndex > 0 && appWindow.currentWallet && !appWindow.currentWallet.viewOnly
                    text: qsTr("Rename") + translationManager.emptyString;
                    onClicked: {
                        isNewAddress = false
                        texIntputDialog.labelTitle = qsTr("Set the label of the selected address:")
                        texIntputDialog.text = appWindow.currentWallet.getSubaddressLabel(appWindow.currentWallet.currentSubaddressAccount, table.currentIndex)
                        texIntputDialog.open()
                    }
                }
            }
        }

        MessageDialog {
            id: trackingHowToUseDialog
            standardButtons: StandardButton.Ok
        }

        InputDialog {
            id: texIntputDialog
            onAccepted: {
                if (isNewAddress) { //create new sub address
                    console.log('On accepted ========')
                    console.log(appWindow.currentWallet.currentSubaddressAccount, texIntputDialog.text)
                    appWindow.currentWallet.subaddress.addRow(appWindow.currentWallet.currentSubaddressAccount, texIntputDialog.text)
                    //table.currentIndex = appWindow.currentWallet.numSubaddresses() - 1
                } else { //change address title
                    appWindow.currentWallet.subaddress.setLabel(appWindow.currentWallet.currentSubaddressAccount, table.currentIndex, texIntputDialog.text)
                }

            }
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
            anchors.top: addressRow.bottom
            anchors.topMargin: 1.5*marginTop
            //Layout.fillWidth: true
            //Layout.minimumHeight: mHeight/3
            width: 200
            height: 200
            x: mWidth/2 - qrCode.width/2
            smooth: false
            fillMode: Image.PreserveAspectFit
            source: "image://qrcode/" + pageReceiveRect.makeQRCodeString()
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
            console.log("Receive page loaded");
            if (!appWindow.currentWallet) return
            table.model = appWindow.currentWallet.subaddressModel;

            if (appWindow.currentWallet) {
                current_address = appWindow.currentWallet.address(appWindow.currentWallet.currentSubaddressAccount, 0)
                appWindow.currentWallet.subaddress.refresh(appWindow.currentWallet.currentSubaddressAccount)
                table.currentIndex = 0
            }

            update()
            timer.running = true
        }

        function onPageClosed() {
            timer.running = false
        }

//        function onPageCompleted() {
//            console.log("Receive page loaded ...");

//            if (appWindow.currentWallet) {
//                console.log("Wallet address: " + appWindow.currentWallet.address)
//                if (addressLine.text.length === 0 || addressLine.text !== appWindow.currentWallet.address) {
//                    addressLine.text = appWindow.currentWallet.address
//                }
//            } else {
//                console.log("current wallet is null")
//            }

//            update()
//            timer.running = true
//        }

//        function onPageClosed() {
//            timer.running = false
//        }
    }

    function onWalletConnected() {
        console.log('[Receive] onWalletConnected')
        pageReceiveRect.onPageCompleted()
    }

    function onWalletClosed() {
        console.log('[Receive] on wallet close')
        //reset all fields
        current_address = ''
        table.model = null

    }

    Component.onCompleted: {
        console.log("======Compoment comleted=======")
        appWindow.walletConnected.connect(onWalletConnected)
        appWindow.walletClosed.connect(onWalletClosed)
    }

} // flickable

