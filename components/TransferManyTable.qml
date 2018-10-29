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
import edollarComponents.Clipboard 1.0

ListView {
    id: listView
    clip: true
    boundsBehavior: ListView.StopAtBounds

//    Rectangle { // the main thing
//        id: viewRect
//        anchors.fill: parent
//        color:  '#e6e6e6'
//        //z: -1
//    }

    footer: Rectangle {
        height: 30
        width: listView.width
        color: "#FFFFFF"
        z: 1
        Text {
            anchors.centerIn: parent
            font.family: "Arial"
            font.pixelSize: 14
            color: "#545454"
            text: qsTr("No more recipient") + translationManager.emptyString
        }
    }

    property var previousItem
    delegate: Rectangle {
        id: delegate
        height: 36
        width: listView.width
        color: index % 2 ? "#F8F8F8" : "#FFFFFF"
        z: listView.count - index
//        function collapseDropdown() { dropdown.expanded = false }

        Clipboard { id: clipboard }

        Image {
            id: deleteAddress
            source: "qrc:///images/delete.png"
            width: 18
            height: 18
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: 5
           // anchors.topMargin: 5
            MouseArea {
                id: deleteAddressArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    console.log("Delete recipent: ", index);
                    transferPage.deleteReceipent(index)
                }
            }
        }

        Text {
            id: amountText
            anchors.left: deleteAddress.right
            anchors.leftMargin: 5
            anchors.top: parent.top
            anchors.topMargin: 5
            width: listView.width/8
            font.family: "Arial"
            font.bold: true
            font.pixelSize: 14
            color: "#444444"
            elide: Text.ElideRight
            text: amount
        }

        TextEdit {
            id: addressText
            selectByMouse: true
            anchors.top: parent.top
            anchors.left: amountText.right
            anchors.leftMargin:  12
            anchors.rightMargin: 40
            anchors.topMargin: 5
            font.family: "Arial"
            font.pixelSize: 12
            color: "#545454"
            text: address
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: "#DBDBDB"
        }
    }
}
