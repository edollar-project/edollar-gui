import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0

import "../common"

Flickable {
    id: flickable
    //contentHeight: root.implicitHeight
    property string name: "Dashboard"
    property string title: qsTr("Dashboard")

    property alias unlockedBalanceText: unlockedBalanceText.text
    property alias balanceLabelText: balanceLabel.text
    property alias balanceText: balanceText.text
    //property alias networkStatus : networkStatus
    //property alias progressBar : progressBar
    property alias minutesToUnlockTxt: unlockedBalanceLabel.text

    property int mWidth: Screen.desktopAvailableWidth
    property int mHeight: Screen.desktopAvailableHeight

    width: mWidth

    Rectangle {
        color: "red"
        width: mWidth
        anchors.topMargin: 50
        x: 0
        id: root
        SearchInput {
            id: searchInput
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: 17
            anchors.rightMargin: 17
            anchors.topMargin: 17
            z: 1
        }

        Text {
            id: quickTransferText
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: searchInput.bottom
            anchors.topMargin: 20
            elide: Text.ElideRight
            anchors.margins: 17
            font.family: "Arial"
            font.pixelSize: 18
            color: "#4A4949"
            text: qsTr("Quick transfer") + translationManager.emptyString
        }

        LineEdit {
            id: quickTransferLine
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: quickTransferText.bottom
            anchors.topMargin: 18
            anchors.leftMargin: 17
            anchors.rightMargin: 17
        }

        Row {
            id: row
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: quickTransferLine.bottom
            anchors.topMargin: 18
            anchors.leftMargin: 17
            anchors.rightMargin: 17
            spacing: 17

            LineEdit {
                id: amountLine
                width: 148
                placeholderText: "amount..."
            }

            StandardButton {
                id: sendButton
                width: 60
                text: qsTr("SEND")
                shadowReleasedColor: "#FF4304"
                shadowPressedColor: "#B32D00"
                releasedColor: "#FF6C3C"
                pressedColor: "#FF4304"
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                font.family: "Arial"
                font.pixelSize: 12
                color: "#545454"
                textFormat: Text.RichText
                text: qsTr("<style type='text/css'>a {text-decoration: none; color: #FF6C3C; font-size: 14px;}</style>\
                            looking for security level and address book? go to <a href='#'>Transfer</a> tab")
                         + translationManager.emptyString
                font.underline: false
                onLinkActivated: appWindow.showPageRequest("Transfer")
            }
        }
/*
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.top: row.bottom
            anchors.topMargin: 17
            color: "#FFFFFF"

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: 1
                color: "#DBDBDB"
            }

            ListModel {
                id: columnsModel
                ListElement { columnName: "Date"; columnWidth: 97 }
                ListElement { columnName: "Amount"; columnWidth: 158 }
                ListElement { columnName: "Balance"; columnWidth: 168 }
            }

            TableHeader {
                id: header
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: 17
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                dataModel: columnsModel
                offset: 145
                onSortRequest: console.log("column: " + column + " desc: " + desc)
            }

            ListModel {
                id: testModel
                ListElement { paymentId: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; date: "Jan 12, 2014"; time: "12:23 <font size='2'>AM</font>"; amount: "0.<font size='2'>000709159241</font>"; balance: "19301.<font size='2'>870709159241</font>"; description: "Client from Australia"; out: false }
                ListElement { paymentId: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; date: "Jan 12, 2014"; time: "12:23 <font size='2'>AM</font>"; amount: "0.<font size='2'>000709159241</font>"; balance: "19301.<font size='2'>870709159241</font>"; description: ""; out: true }
                ListElement { paymentId: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; date: "Jan 12, 2014"; time: "12:23 <font size='2'>AM</font>"; amount: "0.<font size='2'>000709159241</font>"; balance: "19301.<font size='2'>870709159241</font>"; description: ""; out: true }
                ListElement { paymentId: ""; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; date: "Jan 12, 2014"; time: "12:23 <font size='2'>AM</font>"; amount: "0.<font size='2'>000709159241</font>"; balance: "19301.<font size='2'>870709159241</font>"; description: ""; out: false }
                ListElement { paymentId: ""; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; date: "Jan 12, 2014"; time: "12:23 <font size='2'>AM</font>"; amount: "0.<font size='2'>000709159241</font>"; balance: "19301.<font size='2'>870709159241</font>"; description: "Client from Australia"; out: false }
                ListElement { paymentId: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; date: "Jan 12, 2014"; time: "12:23 <font size='2'>AM</font>"; amount: "0.<font size='2'>000709159241</font>"; balance: "19301.<font size='2'>870709159241</font>"; description: ""; out: false }
                ListElement { paymentId: ""; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; date: "Jan 12, 2014"; time: "12:23 <font size='2'>AM</font>"; amount: "0.<font size='2'>000709159241</font>"; balance: "19301.<font size='2'>870709159241</font>"; description: ""; out: false }
                ListElement { paymentId: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; date: "Jan 12, 2014"; time: "12:23 <font size='2'>AM</font>"; amount: "0.<font size='2'>000709159241</font>"; balance: "19301.<font size='2'>870709159241</font>"; description: ""; out: false }
                ListElement { paymentId: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; date: "Jan 12, 2014"; time: "12:23 <font size='2'>AM</font>"; amount: "0.<font size='2'>000709159241</font>"; balance: "19301.<font size='2'>870709159241</font>"; description: "Client from Australia"; out: false }
                ListElement { paymentId: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; address: "faef56b9acf67a7dba75ec01f403497049d7cff111628edfe7b57278554dc798"; date: "Jan 12, 2014"; time: "12:23 <font size='2'>AM</font>"; amount: "0.<font size='2'>000709159241</font>"; balance: "19301.<font size='2'>870709159241</font>"; description: ""; out: false }
            }

            Scroll {
                id: flickableScroll
                anchors.right: table.right
                anchors.rightMargin: -14
                anchors.top: table.top
                anchors.bottom: table.bottom
                flickable: table
            }

            DashboardTable {
                id: table
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: header.bottom
                anchors.bottom: parent.bottom
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                onContentYChanged: flickableScroll.flickableContentYChanged()
                model: testModel
            }
        }
        */
    }

    ScrollIndicator.vertical: ScrollIndicator { }

    // emitting a Signal could be another option
    Component.onDestruction: {
        cleanup()
    }

    function whoAmI() {
        return qsTr("Message from Page One [0]")
    }
    // called immediately after Loader.loaded
    function init() {
        console.log(qsTr("Init done from One [0]"))
    }
    // called from Component.destruction
    function cleanup() {
        console.log(qsTr("Cleanup done from One [0]"))
    }
} // flickable
