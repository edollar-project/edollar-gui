import QtQuick 2.0
import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.4
import QtQuick.Window 2.0

import "../components"
import edollarComponents.Clipboard 1.0

Window {
    id: root
    modality: Qt.ApplicationModal
    flags: Qt.Window | Qt.FramelessWindowHint
    property alias mnemonic: mnemonicText.text
    property alias spendKey: spendKeyText.text
    property alias viewKey: viewKeyText.text
    property alias cancelVisible: cancelButton.visible
    property alias okVisible: okButton.visible
    property alias okText: okButton.text
    property alias cancelText: cancelButton.text

    property var icon

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
    width:  800
    height: 480
    Rectangle {
        id: mainContent
        Text {
           id: dialogTitle
           text: "Mnemonic Seed and Keys"
           color: "#555555"
           font.pixelSize: 24
           anchors.top: parent.top
           x: 280
           anchors.topMargin: 50
        }

        Text {
           id: mnemonic
           text: "Mnemonic"
           color: "#555555"
           anchors.top: dialogTitle.bottom
           x: 40
           anchors.topMargin: 40
        }

        TextArea {
           id: mnemonicText
           text: ""
           textFormat: TextEdit.AutoText
           anchors.top: mnemonic.bottom
           x: 40
           anchors.topMargin: 5
           width: 720
           readOnly: true
           height: 60
        }

        Text {
           id: viewKey
           text: "View Key"
           color: "#555555"
           anchors.top: mnemonicText.bottom
           x: 40
           anchors.topMargin: 10
        }

        TextArea {
           id: viewKeyText
           text: ""
           textFormat: TextEdit.AutoText
           anchors.top: viewKey.bottom
           x: 40
           anchors.topMargin: 5
           width: 720
           readOnly: true
           height: 30
        }

        Text {
           id: spendKey
           text: "Spend Key"
           color: "#555555"
           anchors.top: viewKeyText.bottom
           anchors.topMargin: 30
           x: 40
        }

        TextArea {
           id: spendKeyText
           text: ""
           textFormat: TextEdit.AutoText
           anchors.top: spendKey.bottom
           x: 40
           anchors.topMargin: 5
           width: 720
           readOnly: true
           height: 30
        }

        StandardButton {
            id: cancelButton
            width: 120
            fontSize: 14
            text: qsTr("Cancel")
            onClicked: {
                root.close()
                root.rejected()
            }
        }

        StandardButton {
            id: okButton
            width: 120
            fontSize: 14
            text: qsTr("Ok")
            KeyNavigation.tab: cancelButton
            anchors.top: spendKeyText.bottom
            anchors.topMargin: 50
            x: 360
            onClicked: {
                root.close()
                root.accepted()

            }
        }
    }

}
