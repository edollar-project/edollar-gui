// Copyright (c) 2014-2018, The Monero Project
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

import QtQuick 2.0
import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.4
import QtQuick.Window 2.0

import "../components"
import edollarComponents.AddressBook 1.0
import edollarComponents.AddressBookModel 1.0

Window {
    id: root
    modality: Qt.ApplicationModal
    //flags: Qt.Window | Qt.FramelessWindowHint
    color: "#F0EEEE"
    title: "Address Book"
    property var model

    width: appWindow.mWidth
    height: appWindow.mHeight

    signal accepted()
    signal rejected()

    ColumnLayout {
        anchors.margins: 17
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        spacing: 10

        Label {
            id: addressLabel
            anchors.left: parent.left
            text: qsTr("Address") + translationManager.emptyString
        }

        RowLayout {
            LineEdit {
                Layout.fillWidth: true;
                id: addressLine
                //error: true;
                placeholderText: qsTr("ed...") + translationManager.emptyString
            }
        }

        Label {
            id: descriptionLabel
            text: qsTr("Lable/Description <font size='2'>(Optional)</font>") + translationManager.emptyString
        }

        LineEdit {
            id: descriptionLine
            Layout.fillWidth: true;
            placeholderText: qsTr("Give this entry a name or description") + translationManager.emptyString
        }


        RowLayout {
            id: addButton
            Layout.bottomMargin: 17
            StandardButton {
                text: qsTr("Add") + translationManager.emptyString
                enabled: checkInformation(addressLine.text, appWindow.persistentSettings.testnet)

                onClicked: {
                    if (!appWindow.currentWallet.addressBook.addRow(addressLine.text.trim(), "", descriptionLine.text)) {
                        informationPopup.title = qsTr("Error") + translationManager.emptyString;
                        // TODO: check currentWallet.addressBook.errorString() instead.
                        if(appWindow.currentWallet.addressBook.errorCode() === AddressBook.Invalid_Address)
                             informationPopup.text  = qsTr("Invalid address") + translationManager.emptyString
                        else
                             informationPopup.text  = qsTr("Can't create entry") + translationManager.emptyString

                        informationPopup.onCloseCallback = null
                        informationPopup.open();
                    } else {
                        addressLine.text = "";
                        descriptionLine.text = "";
                    }
                }
            }
        }

    }

    Rectangle {
        id: tableRect
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: parent.height - addButton.y - addButton.height - 36
        color: "#FFFFFF"

        Behavior on height {
            NumberAnimation { duration: 200; easing.type: Easing.InQuad }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 1
            color: "#DBDBDB"
        }

        Scroll {
            id: flickableScroll
            anchors.right: table.right
            anchors.rightMargin: -14
            anchors.top: table.top
            anchors.bottom: table.bottom
            flickable: table
        }

        AddressBookTable {
            id: table
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            onContentYChanged: flickableScroll.flickableContentYChanged()
            model: root.model
        }
    }

    function checkInformation(address, testnet) {
      return walletManager.addressValid(address.trim(), testnet)
    }

    function onPageCompleted() {
        console.log("adress book");
        if (!appWindow.currentWallet) return
        root.model = appWindow.currentWallet.addressBookModel;
    }

    function open() {
        show()
    }

}
