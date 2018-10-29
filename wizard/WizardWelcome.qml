// Copyright (c) 2014-2015, The Monero Project
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
import QtQuick.XmlListModel 2.0
import QtQuick.Layouts 1.1
import QtQml 2.2
import QtQuick.Window 2.3

import "../components"
import "../common"

ColumnLayout {
//    anchors.fill:parent
//    Behavior on opacity {
//        NumberAnimation { duration: 100; easing.type: Easing.InQuad }
//    }

    onOpacityChanged: visible = opacity !== 0

    property int mWidth: (Screen.width < 930)? Screen.width : 930
    width: mWidth
    function onPageClosed(settingsObject) {
        //set default language as we support english only at this moment
        settingsObject['language'] = "English (US)"
        settingsObject['wallet_language'] = "English"
        settingsObject['locale'] = "en_US"
        return true
    }

    ColumnLayout {
        id: headerColumn
        Layout.leftMargin: wizardLeftMargin
        Layout.rightMargin: wizardRightMargin
        Layout.bottomMargin: 40
        spacing: 20

        Text {
            Layout.fillWidth: true
            font.family: "Arial"
            font.pixelSize: 32
            font.bold: true
            color: "#303F9F"
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Welcome to eDollar!")
        }

        Text {
            Layout.fillWidth: true
            font.family: "Arial"
            font.pixelSize: 18
            color: "#4A4646"
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            textFormat: Text.RichText
            text: qsTr("<style type='text/css'>{text-decoration: none; color: #FF6C3C; font-size: 18px;}</style>\
                        Electronic Dollar (or eDollar) is a private, secure, untraceable, decentralised digital currency. You are your bank, you control your funds, and nobody can trace your transfers unless you allow them to do so. \n
                        For more information, please visit our website <a href='#'>https://edollar.cash</a> \n
                        Or contact us via email <a href='#'>hello@edollar.cash</a> ")
        }

        RowLayout {
            //id: nextButtonLayout
            Layout.leftMargin: mWidth / 2 - 30 - wizardLeftMargin
            Layout.topMargin: 40
            StandardButton {
                id: nextPage
                width: 60
                text: qsTr("Next")
                shadowReleasedColor: "#3F51B5"
                shadowPressedColor: "#303F9F"
                releasedColor: "#3F51B5"
                pressedColor: "#303F9F"
                enabled : true
                onClicked: {
                    console.log("with: <<" + mWidth)
                    wizard.switchPage(true)
                }
            }
        }

    }



}
