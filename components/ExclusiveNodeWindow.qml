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

import QtQuick 2.0
import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.4
import QtQuick.Window 2.0

import "../components"

Window {
    id: root
    modality: Qt.ApplicationModal
    //flags: Qt.Window | Qt.FramelessWindowHint
    color: "#F0EEEE"
    title: "Exclusive node setting"
    property var model

    width: 360
    height: 480
    maximumWidth: 360

    signal accepted()
    signal rejected()

    ColumnLayout {
        anchors.margins: 17
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        spacing: 10

        Label {
            id: addressNodeLabel
            text: qsTr("Exclusive node address or peer") + translationManager.emptyString
        }

        LineEdit {
            id: addressNodeLine
            Layout.fillWidth: true;
            placeholderText: qsTr("ip:port (ex: 80.211.162.91:33030)") + translationManager.emptyString
        }


        RowLayout {
            id: addButton
            Layout.bottomMargin: 17
            StandardButton {
                text: qsTr("Add") + translationManager.emptyString
                enabled: checkInformation(addressNodeLine.text)

                onClicked: {
                    settingPage.addExclusiveNode(addressNodeLine.text)
                    addressNodeLine.text = ""
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

        ExclusiveNodeTable {
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

    function checkInformation(addressNode) {
        var arr = addressNode.split(':')
        if (arr.length !== 2) return false
        //TODO: check ip, port
        if (arr[0].split('.').length !== 4) return false
        return true
    }

    function onPageCompleted() {
//        console.log("adress book");
//        if (!appWindow.currentWallet) return
//        root.model = appWindow.currentWallet.addressBookModel;
    }

    function open() {
        show()
    }

}
