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

import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0
import QtQuick.Window 2.2
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0
import "../common"
import QtQuick.Dialogs 1.2
import edollarComponents.PendingTransaction 1.0
import "../components"
import edollarComponents.Wallet 1.0

import edollarComponents.WalletManager 1.0
import edollarComponents.TransactionHistory 1.0
import edollarComponents.TransactionInfo 1.0
import edollarComponents.TransactionHistoryModel 1.0

import QtQuick.Window 2.2
import "../../version.js" as Version

Flickable {
    id: root
    property var model
    //contentHeight: dashboardPage.implicitHeight
    property string name: "Dashboard"
    property string title: qsTr("Dashboard")

    property int mWidth: appWindow.mWidth
    //property int mHeight: Screen.desktopAvailableHeight
    property int marginLeft: appWindow.mWidth/8
    property int marginTop: 20

    property alias unlockedBalanceText: unlockedBalanceText.text
    property alias balanceLabelText: balanceLabel.text
    property alias balanceText: balanceText.text
    property alias networkStatus : networkStatus
    property alias progressBar : progressBar

    property alias infoNetHash: infoNetHash.text
    property alias infoCurrenHeight: infoCurrenHeight.text

    //recent transaction
    property alias txid: txid.text
    property alias direction: direction.text
    property alias amount: amount.text
    property alias dateTime: dateTime.text
    property alias txStatus: txStatus.text

    property bool enabledViewButton: false

//    property alias blockHeight: blockHeight.text
//    property alias isPending: isPending.text
//    property alias dateTime: dateTime.text

    property int regionWidth: 6*marginLeft

    onModelChanged: {
        console.log('[Dashboard] Model Changed')
        root.updateRecentTransaction()

    }

    ColumnLayout {
        anchors.fill: parent
        spacing: marginTop
        //balance
        RowLayout {
            Layout.topMargin: 1.5*marginTop
            Layout.leftMargin: marginLeft
            Layout.preferredWidth: regionWidth
            ColumnLayout {
                Layout.preferredWidth: 4*marginLeft
                RowLayout {
                    Layout.preferredWidth: 4*marginLeft
                    Label {
                      id: balanceLabel
                      Layout.preferredWidth: 3*marginLeft
                      text: "Balance"
                      fontSize: 16
                      color: "#222"
                    }
                    Text {
                        id: balanceText
                        font.family: "Arial"
                        color: "#7ca128"
                        font.pixelSize: 18
                        font.bold: true
                        text: "0.000000000"
                        Layout.preferredWidth: marginLeft
                    }
                }
                RowLayout {
                    Layout.preferredWidth: 4*marginLeft
                    Label {
                      id: unlockedBalanceLabel
                      width: 3*marginLeft
                      text: "Unlocked Balance"
                      fontSize: 16
                      color: "#222"
                    }
                    Text {
                        id: unlockedBalanceText
                        Layout.leftMargin: 2*leftMargin
                        font.pixelSize: 18
                        font.bold: true
                        font.family: "Arial"
                        color: "#7ca128"
                        text: "0.000000000"
                        width: marginLeft
                    }
                }
            }

            RowLayout {
                //Layout.preferredWidth: 2*marginLeft
                Image {
                    id: tooltipInfo
                    width: 18
                    height: 18
                    Layout.leftMargin: 0
                    fillMode: Image.PreserveAspectFit
                    horizontalAlignment: Image.AlignRight
                    verticalAlignment: Image.AlignTop
                    //anchors.centerIn: parent
                    source: "qrc:///images/tooltipInfo.png"
                    visible: false

                    MouseArea {
                        id: tooltipInfoWalletArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            tooltipInfoPopup.title = 'Information'
                            tooltipInfoPopup.text = 'The balance may be not correct as the view only wallet does not hold the key images which are necessary to decode the outgoing transactions, It can detect only incoming EDL'
                            tooltipInfoPopup.cancelVisible = false
                            tooltipInfoPopup.open()
                        }
                    }
                }

                StandardButton {
                    id: rescanSpent
                    Layout.preferredWidth: marginLeft/2
                    Layout.leftMargin: tooltipInfo.visible? marginLeft/2 - 50: marginLeft/2
                    height: 40
                    text: qsTr("Rescan Balance")
                    enabled : true

                    onClicked: {
                        if (!appWindow.currentWallet.rescanSpent()) {
                            console.error("Error: ", appWindow.currentWallet.errorString);
                            informationPopup.title = qsTr("Error") + translationManager.emptyString;
                            informationPopup.text  = qsTr("Error: ") + appWindow.currentWallet.errorString
                            informationPopup.icon  = StandardIcon.Critical
                            informationPopup.onCloseCallback = null
                            informationPopup.open();
                        } else {
                            informationPopup.title = qsTr("Information") + translationManager.emptyString
                            informationPopup.text  = qsTr("Successfully rescanned spent outputs.") + translationManager.emptyString
                            informationPopup.icon  = StandardIcon.Information
                            informationPopup.onCloseCallback = null
                            informationPopup.open();
                        }
                    }
                }

            }
        }

        RowLayout {
            Layout.leftMargin: marginLeft
            Layout.topMargin: marginTop
            Rectangle {
                id: hDivider1
                height: 1
                width: regionWidth
                color: "#bfbfbf"
            }
        }

        RowLayout {
            Layout.leftMargin: marginLeft
            Layout.preferredWidth: regionWidth
            ColumnLayout {
                RowLayout {
                    Layout.preferredWidth: regionWidth
                    Text {
                      id: recentTransactionLabel
                      width: regionWidth
                      Layout.preferredWidth: regionWidth
                      horizontalAlignment: Text.AlignHCenter
                      text: "LATEST TRANSACTION"
                      font.pixelSize: 22
                      color: "#222222"
                    }
                }
                RowLayout {
                    Layout.topMargin: marginTop
                    Text {
                        id: direction
                        text: qsTr("")
                        font.pixelSize: 22
                        color: "#d9d9d9"
                        verticalAlignment: Text.AlignVCenter
                    }
                    ColumnLayout {
                        Layout.leftMargin: 15
                        spacing: 5
                        RowLayout {
                            Text {
                                id: txid
                                font.family: "Arial"
                                font.pixelSize: 16
                                color: "#d9d9d9"
                                text: qsTr("No transaction")
                            }
                        }
                        RowLayout {
                            spacing: 5
                            Text {
                                id: amount
                                font.family: "Arial"
                                font.pixelSize: 16
                                color: "#ff4000"
                                text: qsTr("")
                            }
                            Text {
                                Layout.leftMargin: 40
                                id: dateTime
                                font.family: "Arial"
                                font.pixelSize: 16
                                color: "#333333"
                                text: qsTr("")
                            }
                            Text {
                                Layout.leftMargin: 40
                                id: txStatus
                                font.family: "Arial"
                                font.pixelSize: 16
                                text: qsTr("")
                            }
                        }
                    }
                }

            }

        }


        RowLayout {
            Layout.leftMargin: marginLeft
            Layout.topMargin: marginTop
            Rectangle {
                id: hDivider2
                height: 1
                width: regionWidth
                color: "#bfbfbf"
            }
        }

        ColumnLayout {
            Layout.leftMargin: marginLeft
            Layout.preferredWidth: regionWidth
            RowLayout {
                Layout.preferredWidth: regionWidth
                Image {
                    id: spendableImage
                    width: 24
                    height: 24
                    fillMode: Image.PreserveAspectFit
                    horizontalAlignment: Image.AlignRight
                    verticalAlignment: Image.AlignTop
                    //anchors.centerIn: parent
                    source: "qrc:///images/spendableType.png"
                    visible: false
                }
                Image {
                    id: viewOnlyImage
                    width: 24
                    height: 24
                    fillMode: Image.PreserveAspectFit
                    horizontalAlignment: Image.AlignRight
                    verticalAlignment: Image.AlignTop
                    //anchors.centerIn: parent
                    source: "qrc:///images/viewOnlyType.png"
                    visible: false
                }
                Text {
                    id: walletType
                    width: marginLeft
                    font.family: "Arial"
                    font.pixelSize: 20
                    color: "#4A4646"
                    wrapMode: Text.Wrap
                    text: appWindow.currentWallet? (appWindow.currentWallet.viewOnly? 'View Only Wallet': 'Spendable Wallet') : ''
                }

                StandardButton {
                    id: createViewWallet
                    Layout.leftMargin: 2*marginLeft - 64
                    width: marginLeft
                    height: 40
                    text: qsTr("Create view only wallet")
                    enabled : enabledViewButton
                    onClicked: {
                        createViewWalletPopup.title = qsTr("Confirmation") + translationManager.emptyString
                        createViewWalletPopup.text  = qsTr("You are about creating new view only wallet. This wallet will be closed")
                        createViewWalletPopup.icon = StandardIcon.Question
                        createViewWalletPopup.open()
                    }
                }
                StandardButton {
                    id: colseWallet
                    Layout.leftMargin: 32
                    width: marginLeft
                    height: 40
                    text: qsTr(" Close this wallet ")
                    enabled : true
                    onClicked: {
                        appWindow.closeCurrentWallet()
                    }
                }

            }

            RowLayout {
                Layout.topMargin: 15
                Text {
                    Layout.preferredWidth: 2*marginLeft
                    id: infoWalletName
                    font.family: "Arial"
                    font.pixelSize: 14
                    color: "#4A4646"
                    wrapMode: Text.Wrap
                    text: 'Wallet name:'
                }
                Text {
                    id: infoWalletVersion
                    font.family: "Arial"
                    font.pixelSize: 14
                    color: "#4A4646"
                    wrapMode: Text.Wrap
                    text: 'Version:'
                    Layout.preferredWidth: 1.5*marginLeft
                    Layout.leftMargin: 0.5*marginLeft
                }
                Text {
                    id: infoWalletHeight
                    font.family: "Arial"
                    font.pixelSize: 14
                    color: "#4A4646"
                    wrapMode: Text.Wrap
                    text: 'Created at height:'
                }
            }
            RowLayout {
                Layout.topMargin: topMargin/2
                Text {
                    id: infoWalletLog
                    font.family: "Arial"
                    font.pixelSize: 14
                    color: "#4A4646"
                    wrapMode: Text.Wrap
                    text: 'Log file:'
                    Layout.preferredWidth: regionWidth
                }
            }
            RowLayout {
                Layout.topMargin: topMargin/2
                Text {
                    id: infoDaemonVerion
                    font.family: "Arial"
                    font.pixelSize: 14
                    color: "#4A4646"
                    wrapMode: Text.Wrap
                    text: 'Edollar embeded version: '
                    Layout.preferredWidth: regionWidth
                }
            }

        }

        RowLayout {
            Layout.leftMargin: marginLeft
            anchors.bottom: parent.bottom
            Layout.bottomMargin: 20
            NetworkStatusItem {
                id: networkStatus
                width: regionWidth/2
                Layout.preferredWidth: regionWidth/2
                connected: Wallet.ConnectionStatus_Disconnected
            }
            ColumnLayout {
                spacing: 5
                RowLayout {
                    Layout.topMargin: 5
                    Text {
                        id: infoCurrenHeight
                        font.family: "Arial"
                        font.pixelSize: 14
                        color: "#4A4646"
                        wrapMode: Text.Wrap
                        text: 'Current block:'
                    }
                    Text {
                        id: infoNetHash
                        font.family: "Arial"
                        font.pixelSize: 14
                        color: "#4A4646"
                        wrapMode: Text.Wrap
                        text: 'Network hashrate:'
                    }
                }
                ProgressBar {
                    id: progressBar
                    width: regionWidth/2
                    Layout.bottomMargin: 15
                }
            }

        }


    } // pane root
    function updateWalletBalance(balanceAmount, unlockedAmount) {
        root.balanceLabelText = balanceAmount
        root.unlockedBalanceText = unlockedAmount
    }

    function updateRecentTransaction() {
        //if (model === null || typeof root.model !== 'undefined')
        //    root.model = appWindow.currentWallet ? appWindow.currentWallet.historyModel : null

        if (typeof root.model !== 'undefined' && root.model) {
            var countItem = root.model.rowCount()
            console.log('updateRecentTransaction, Count=', countItem)
            if (countItem <= 0) {
                console.log('updateRecentTransaction, Nothing to update')
                return
            }
            root.model.sortRole = TransactionHistoryModel.TransactionTimeStampRole
            root.model.sort(0, Qt.DescendingOrder);

            var idx = root.model.index(0, 0)
            var isOut = root.model.data(idx, TransactionHistoryModel.TransactionIsOutRole);
            var value = root.model.data(idx, TransactionHistoryModel.TransactionDisplayAmountRole);
            var isPending = root.model.data(idx, TransactionHistoryModel.TransactionPendingRole);
            var blockHeight = root.model.data(idx, TransactionHistoryModel.TransactionBlockHeightRole);
            var txDate = root.model.data(idx, TransactionHistoryModel.TransactionDateRole);
            var txTime = root.model.data(idx, TransactionHistoryModel.TransactionTimeRole);
            var txHash = root.model.data(idx, TransactionHistoryModel.TransactionHashRole);
            var confirmation = root.model.data(idx, TransactionHistoryModel.TransactionConfirmationsRole);
            var confirmationRequired = 10 //we fixed it

            console.log('txhash ', txHash, ' out ', isOut)

            txid.color = '#333333'
            txid.text = txHash
            if (isOut) {
                direction.color = '#e04679'
                amount.color = '#e04679'
                txStatus.color = '#e04679'
                direction.text = 'SENT'
                txStatus.text = isPending? 'Pending' : 'Confirmed'
            } else {
                direction.color = '#7ca128'
                amount.color = '#7ca128'
                txStatus.color = '#7ca128'
                direction.text = 'RECEIVE'
                txStatus.text = isPending? 'Pending' : (confirmation <= confirmationRequired? 'confirmation (' + confirmation + '/' + confirmationRequired + ')' : 'confirmed')
            }
            amount.text = value
            dateTime.text = txDate + '@' + txTime

        }
    }

    ScrollIndicator.vertical: ScrollIndicator { }

    StandardDialog {
        id: createViewWalletPopup
        onAccepted: {
           close();
           appWindow.createViewOnlyWallet()
        }
    }

    StandardDialog {
        id: tooltipInfoPopup
        onAccepted: {
           close()
        }
    }
    // emitting a Signal could be another option
    Component.onDestruction: {
        //cleanup()
        statusTimer.stop()
    }

    Component.onCompleted: {
        console.log('Dashboard>> page completed')
        root.onPageCompleted()
        appWindow.walletConnected.connect(onWalletConnected)
        appWindow.walletClosed.connect(onWalletClosed)
        appWindow.historyChanged.connect(onHistoryChanged)
        if(typeof daemonManager != "undefined") {
            daemonManager.daemonConsoleUpdated.connect(onDaemonConsoleUpdated)
            daemonManager.daemonStarted.connect(onDaemonStarted);
            daemonManager.daemonStopped.connect(onDaemonStopped);
        }
        statusTimer.start()

    }

    Timer {
        id: statusTimer
        interval: 30000
        repeat: true
        onTriggered: {
            console.log('Timer trigger ', appWindow.remoteNodeConnected)
            statusTimer.running = true
            if(typeof daemonManager != "undefined" && appWindow.daemonRunning) {
                daemonManager.sendCommand("status", false);
            } /*else if (appWindow.remoteNodeConnected) {
                //change status ...
                console.log('Change status node ...')
                infoCurrenHeight.text = 'Wallet sync to remote node'
                infoNetHash.text = ''
            }*/
        }
    }

    function onDaemonStarted() {
        networkStatus.connected = true
    }

    function onDaemonStopped() {
        networkStatus.connected = false
    }

    function onHistoryChanged() {
        console.log('[Dashboard] onHistoryChanged')
        root.updateRecentTransaction()
    }

    function onDaemonConsoleUpdated(message) {
        console.log('daemon updated ', message)
        var arrMessage = message.split(/[\s]/)
        if (arrMessage.lenght < 2)
            return
        if (arrMessage[0] !== 'Height:')
            return
        var blocks = arrMessage[1].split("/")
        if (blocks.length !== 2)
            return
        var currentBlock = parseInt(blocks[0])
        var targetBlock = parseInt(blocks[1])

        console.log(currentBlock, '/', targetBlock)

        //check if daemon is really connect to network
        arrMessage = message.split(",")
        //console.log('arrMessage.lenght', arrMessage.length)
        if (arrMessage.length !== 7)
            return
        //console.log('arrMessage[5].trimmed()', arrMessage[5])
        if (arrMessage[5] === " 0(out)+0(in) connections" || arrMessage[5] === "0(out)+0(in) connections")
        {
            console.log('Get fake synced,', arrMessage[5])
            return
        }
        progressBar.updateSyncProgress(currentBlock, targetBlock)
        infoCurrenHeight.text = 'Current block: ' + targetBlock
        infoNetHash.text = '- Network hashrate: ' + arrMessage[2].substring(9)

        //fully synced, load show wallet refresh
        if (currentBlock >= targetBlock) {
            appWindow.daemonFullySynced()
            networkStatus.connected = true
        }
    }

    function onWalletConnected() {
        console.log('[Dashboard] onWalletConnected')
        console.log('On wallet connected, ', appWindow.currentWallet? 'OK':'NULL')
        if (appWindow.remoteNodeConnected) {
            networkStatus.connected = 1
        }
        if (!appWindow.currentWallet) {
            root.model = null
            return
        }

        enabledViewButton = !appWindow.currentWallet.viewOnly
        tooltipInfo.visible = appWindow.currentWallet.viewOnly
        root.model = appWindow.currentWallet.historyModel
        console.log('Dashboard, on model change ', root.model? 'NOT NULL ' : 'NULL')
        root.updateRecentTransaction()
        if (appWindow.currentWallet.viewOnly) {
            spendableImage.visible = false
            viewOnlyImage.visible = true
        } else {
            spendableImage.visible = true
            viewOnlyImage.visible = false
        }
        infoWalletName.text = 'Walle name: ' + appWindow.walletName
        infoWalletVersion.text = 'Version: ' + Version.GUI_VERSION
        infoWalletHeight.text = 'Created at height: ' + appWindow.currentWallet.walletCreationHeight
        infoWalletLog.text = 'Log file: ' + appWindow.currentWallet.walletLogPath
        infoDaemonVerion.text = 'Edollar embeded version: ' + Version.GUI_MONERO_VERSION

    }

    function onWalletClosed() {
        console.log('[Dashboard] on wallet close')
        //reset all field
        balanceText.text = '0.000000000'
        unlockedBalanceText.text = '0.000000000'
        amount.text = ''
        txid.color = '#d9d9d9'
        txid.text = 'No transaction'
        direction.text = ''
        txStatus.text = ''
        dateTime.text = ''
        infoWalletName.text = 'Walle name: '
        infoWalletVersion.text = 'Version: '
        infoWalletHeight.text = 'Created at height: '
        infoWalletLog.text = 'Log file: '
        infoDaemonVerion.text = 'Edollar embeded version: '

        root.model = null

        enabledViewButton = false
        //statusTimer.stop()
        tooltipInfo.visible = false
    }

    function onPageCompleted() {

        //console.log('onPageCompleted=============', root.model.rowCount())
        //root.updateRecentTransaction()
    }
} // flickable
