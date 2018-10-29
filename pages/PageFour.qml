// ekke (Ekkehard Gentz) @ekkescorner
import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0
import "../common"

import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0
import "../common"
import QtQuick.Dialogs 1.2
import edollarComponents.PendingTransaction 1.0
import "../components"
import edollarComponents.Wallet 1.0

import QtQuick.Window 2.2


import QtQuick.Window 2.2

Flickable {
    id: flickable
    contentHeight: root.implicitHeight
    // StackView manages this, so please no anchors here
    // anchors.fill: parent
    property string name: "PageFour"
    property string title: qsTr("Truck")

    property int mWidth: Screen.desktopAvailableWidth
    property int mHeight: Screen.desktopAvailableHeight
    property int marginLeft: mWidth/8

    Pane {
        id: root
        anchors.fill: parent
        ColumnLayout {
            anchors.right: parent.right
            anchors.left: parent.left
            LineEdit {
                width: 500

            }
            HorizontalDivider {}

            RowLayout {
                LabelSubheading {
                    topPadding: 6
                    bottomPadding: 6
                    leftPadding: 10
                    rightPadding: 10
                    wrapMode: Text.WordWrap
                    text: qsTr("Navigate between Pages:\n* Swipe with your fingers\n* Tap on a Tab\n* Tap on a Button\n\nTap on 'Settings' Button to configure TabBar\n\nFrom 'Option Menu' (three dots) placed top right in ToolBar you can switch Theme and change primary / accent colors\n\nBluetooth keyboard attached or BlackBerry PRIV?\n* Type '1', '2', '3', '4', '5' to go to the specific Tab\n* 'Space' or 'n' for the next Tab\n* 'Shift Space' or 'p' for the previous Tab\n")
                }
                ComboBox {
                    editable: false
                    model: ListModel {
                        id: model
                        ListElement { text: "Banana"; color: "Yellow" }
                        ListElement { text: "Apple"; color: "Green" }
                        ListElement { text: "Coconut"; color: "Brown" }
                    }
                    onAccepted: {
                        if (find(currentText) === -1) {
                            model.append({text: editText})
                            currentIndex = find(editText)
                        }
                    }
                }
            }
            HorizontalDivider {}
            RowLayout {
                // implicite fillWidth = true
                spacing: 10
                ButtonIconActive {
                    imageName: tabButtonModel[2].icon
                    imageSize: 48
                    onClicked: {
                        navPane.goToPage(2)
                    }
                }
                ButtonIconActive {
                    imageName: tabButtonModel[4].icon
                    imageSize: 48
                    onClicked: {
                        navPane.goToPage(4)
                    }
                }
            } // button row
            HorizontalDivider {}
            TextInput {
                height: 28
            }
        } // col layout
    } // pane root
    ScrollIndicator.vertical: ScrollIndicator { }

    // emitting a Signal could be another option
    Component.onDestruction: {
        cleanup()
    }
} // flickable
