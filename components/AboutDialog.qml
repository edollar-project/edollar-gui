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
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.4
import QtQuick.Window 2.0

import "../components" as EdollarComponents

Window {
    id: root
    modality: Qt.ApplicationModal
    flags: Qt.Window | Qt.FramelessWindowHint
    property alias title: dialogTitle.text
    property alias text: dialogContent.text
    property alias content: root.text
    property alias cancelVisible: cancelButton.visible
    property alias okVisible: okButton.visible
    property alias textArea: dialogContent
    property alias okText: okButton.text
    property alias cancelText: cancelButton.text


    // same signals as Dialog has
    signal accepted()
    signal rejected()

    // Make window draggable
    MouseArea {
        anchors.fill: parent
        property point lastMousePos: Qt.point(0, 0)
        onPressed: { lastMousePos = Qt.point(mouseX, mouseY); }
        onMouseXChanged: root.x += (mouseX - lastMousePos.x)
        onMouseYChanged: root.y += (mouseY - lastMousePos.y)
    }

    function open() {
        show()
    }

    // TODO: implement without hardcoding sizes
    width:  640
    height: 360

    ColumnLayout {
        id: mainLayout
        spacing: 10
        anchors { fill: parent; margins: 35 }

        RowLayout {
            id: column
            Layout.alignment: Qt.AlignHCenter
            Image {
                id: edollarIcon
                width: 64
                height: 64
                fillMode: Image.PreserveAspectFit
                horizontalAlignment: Image.AlignRight
                verticalAlignment: Image.AlignTop
                source: "qrc:///images/edollar-icon.png"
            }
            //anchors {fill: parent; margins: 16 }

            Label {
                id: dialogTitle
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 40
                font.family: "Arial"
                color: "#555555"
                Layout.leftMargin: 20
            }

        }

        RowLayout {
            Layout.topMargin: 30
            TextArea {
                id : dialogContent
                Layout.fillWidth: true
                //Layout.fillHeight: true
                Layout.preferredHeight: 120
                font.family: "Arial"
                textFormat: TextEdit.AutoText//Text.RichText
                readOnly: true
                font.pixelSize: 12
            }
        }

        // Ok/Cancel buttons
        RowLayout {
            id: buttons
            spacing: 60
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 30
            EdollarComponents.StandardButton {
                id: cancelButton
                width: 120
                fontSize: 14
                text: qsTr("Cancel") + translationManager.emptyString
                onClicked: {
                    root.close()
                    root.rejected()
                }
            }

            EdollarComponents.StandardButton {
                id: okButton
                width: 120
                fontSize: 14
                text: qsTr("Ok")
                KeyNavigation.tab: cancelButton
                onClicked: {
                    root.close()
                    root.accepted()

                }
            }
        }
    }

}



