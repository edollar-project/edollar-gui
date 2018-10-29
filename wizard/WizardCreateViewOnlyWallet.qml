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
import QtQuick.Dialogs 1.2
import edollarComponents.Wallet 1.0
import QtQuick.Layouts 1.1
import 'utils.js' as Utils

ColumnLayout {
    opacity: 0
    visible: false

    Behavior on opacity {
        NumberAnimation { duration: 100; easing.type: Easing.InQuad }
    }

    property bool signalRequested: false

    onOpacityChanged: visible = opacity !== 0

    function onWizardRestarted() {
        // reset account name field
        uiItem.accountNameText = defaultAccountName
        uiItem.recoverFromKeysAddress = ""
        uiItem.recoverFromKeysViewKey = ""
        signalRequested = false
    }

    function onPageOpened(settingsObject) {
        console.log("on page opened")
        uiItem.checkNextButton();
    }

    function onPageClosed(settingsObject) {
        settingsObject['account_name'] = uiItem.accountNameText
        settingsObject['wallet_path'] = uiItem.walletPath
        settingsObject['recover_address'] = uiItem.recoverFromKeysAddress
        settingsObject['recover_viewkey'] = uiItem.recoverFromKeysViewKey


        var restoreHeight = parseInt(uiItem.restoreHeight);
        settingsObject['restore_height'] = isNaN(restoreHeight)? 0 : restoreHeight
        var walletFullPath = wizard.createWalletPath(uiItem.walletPath,uiItem.accountNameText);
        if(!wizard.walletPathValid(walletFullPath)){
           return false
        }
        return recoveryWallet(settingsObject)
    }

    function recoveryWallet(settingsObject) {
        var testnet = appWindow.persistentSettings.testnet;
        var restoreHeight = settingsObject.restore_height;
        var tmp_wallet_filename = oshelper.temporaryFilename()
        console.log("Creating temporary wallet", tmp_wallet_filename)

        var wallet = walletManager.createWalletFromKeys(tmp_wallet_filename, settingsObject.wallet_language, testnet,
                                                            settingsObject.recover_address, settingsObject.recover_viewkey,
                                                            settingsObject.recover_spendkey, restoreHeight)


        var success = wallet.status === Wallet.Status_Ok;
        if (success) {
            settingsObject['wallet'] = wallet;
            settingsObject['tmp_wallet_filename'] = tmp_wallet_filename
        } else {
            console.log(wallet.errorString)
            walletErrorDialog.text = wallet.errorString;
            walletErrorDialog.open();
            walletManager.closeWallet();
        }
        return success;
    }

    function onViewOnlyWalletRequested(accountName, viewKey, mainAddress, walletHeight) {
        console.log('[WizardCreateViewOnlyWallet] onsignal, accountName=', accountName, ' viewKey=', viewKey, ' mainAddress=', mainAddress)
        uiItem.accountNameText = accountName
        uiItem.recoverFromKeysAddress = mainAddress
        uiItem.recoverFromKeysViewKey = viewKey
        uiItem.restoreHeight = walletHeight
        signalRequested = true
    }

    WizardCreateViewOnlyWalletUI {
        id: uiItem
        accountNameText: defaultAccountName
        titleText: qsTr("Create View Only Wallet") + translationManager.emptyString
        restoreHeightVisible: true
    }

    Component.onCompleted: {
        parent.wizardRestarted.connect(onWizardRestarted)
        appWindow.viewOnlyWalletRequested.connect(onViewOnlyWalletRequested)
    }
}
