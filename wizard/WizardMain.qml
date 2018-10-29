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
import Qt.labs.settings 1.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

import "../components"

ColumnLayout {
    anchors.fill: parent
    Layout.fillHeight: true
    id: wizard
    property alias nextButton : nextButton
    property var settings : ({})
    property int currentPage: 0
    property int wizardLeftMargin: 80
    property int wizardRightMargin: 25
    property int wizardBottomMargin: 25
    property int wizardTopMargin: 50

    property var paths: {
     //   "create_wallet" : [welcomePage, optionsPage, createWalletPage, passwordPage, donationPage, finishPage ],
     //   "recovery_wallet" : [welcomePage, optionsPage, recoveryWalletPage, passwordPage, donationPage, finishPage ],
        // disable donation page
        "create_wallet" : [optionsPage, createWalletPage, passwordPage,  finishPage ],
        //"create_wallet" : [optionsPage, createWalletPage, passwordPage,  finishPage ],
        "recovery_wallet" : [optionsPage, recoveryWalletPage, passwordPage,  finishPage ],
        "create_view_only_wallet" : [optionsPage, createViewOnlyWalletPage, passwordPage, finishPage ],

    }
    property string currentPath: "create_wallet"
    property var pages: paths[currentPath]

    signal wizardRestarted();
    signal useEdollarClicked()
    signal openWalletFromFileClicked()

    function restart(){
        wizard.currentPage = 0;
        //wizard.settings = ({})
        wizard.currentPath = "create_wallet"
        wizard.pages = paths[currentPath]
        wizardRestarted();

        //hide all pages except first
        for (var i = 1; i < wizard.pages.length; i++){
            wizard.pages[i].opacity = 0;
        }
        //Show first pages
        wizard.pages[0].opacity = 1;

    }

    function switchPage(next) {
        // save settings for current page;
        if (next && typeof pages[currentPage].onPageClosed !== 'undefined') {
            if (pages[currentPage].onPageClosed(settings) !== true) {
                print ("Can't go to the next page");
                return;
            };

        }
        console.log("switchpage: currentPage: ", currentPage);

        // Update prev/next button positions for mobile/desktop
        prevButton.anchors.verticalCenter = (!isMobile) ? wizard.verticalCenter : undefined
        prevButton.anchors.bottom = (isMobile) ? wizard.bottom : undefined
        nextButton.anchors.verticalCenter = (!isMobile) ? wizard.verticalCenter : undefined
        nextButton.anchors.bottom = (isMobile) ? wizard.bottom : undefined

        if (currentPage > 0 || currentPage < pages.length - 1) {
            pages[currentPage].opacity = 0
            var step_value = next ? 1 : -1
            currentPage += step_value
            pages[currentPage].opacity = 1;

            var nextButtonVisible = currentPage >= 1 && currentPage < pages.length - 1
            nextButton.visible = nextButtonVisible

            if (typeof pages[currentPage].onPageOpened !== 'undefined') {
                pages[currentPage].onPageOpened(settings,next)
            }
        }
    }

    function openCreateWalletPage() {
        wizardRestarted();
        print ("show create wallet page");
        currentPath = "create_wallet"
        pages = paths[currentPath]
        createWalletPage.createWallet(settings)
        wizard.nextButton.visible = true
        // goto next page
        switchPage(true);
    }

    function openRecoveryWalletPage() {
        wizardRestarted();
        print ("show recovery wallet page");
        currentPath = "recovery_wallet"
        pages = paths[currentPath]
        wizard.nextButton.visible = true
        // goto next page
        switchPage(true);
    }

    function openOpenWalletPage() {
        console.log("open wallet from file page");
        if (typeof wizard.settings['wallet'] !== 'undefined') {
            //settings.wallet.destroy();
            delete wizard.settings['wallet'];
        }
        optionsPage.onPageClosed(settings)
        wizard.openWalletFromFileClicked();
    }

    function openCreateViewOnlyWalletPage(){
        pages[currentPage].opacity = 0
        currentPath = "create_view_only_wallet"
        pages = paths[currentPath]
        currentPage = pages.indexOf(createViewOnlyWalletPage)
        createViewOnlyWalletPage.opacity = 1
        nextButton.visible = true
        nextButton.enabled = createViewOnlyWalletPage.signalRequested
        rootItem.state = "wizard";
    }

    function createWalletPath(folder_path,account_name){

        // Remove trailing slash - (default on windows and mac)
        if (folder_path.substring(folder_path.length -1) === "/"){
            folder_path = folder_path.substring(0,folder_path.length -1)
        }

        // Store releative path on ios.
        if(isIOS)
            folder_path = "";

        return folder_path + "/" + account_name + "/" + account_name
    }

    function walletPathValid(path){
        if(isIOS)
            path = edollarAccountsDir + path;
        if (walletManager.walletExists(path)) {
            walletErrorDialog.text = qsTr("A wallet with same name already exists. Please change wallet name") + translationManager.emptyString;
            walletErrorDialog.open();
            return false;
        }

        // Don't allow non ascii characters in path on windows platforms until supported by Wallet2
        if (isWindows) {
            if (!isAscii(path)) {
                walletErrorDialog.text = qsTr("Non-ASCII characters are not allowed in wallet path or account name")  + translationManager.emptyString;
                walletErrorDialog.open();
                return false;
            }
        }
        return true;
    }

    function isAscii(str){
        for (var i = 0; i < str.length; i++) {
            if (str.charCodeAt(i) > 127)
                return false;
        }
        return true;
    }

    //! actually writes the wallet
    function applySettings() {
        // Save wallet files in user specified location
        var new_wallet_filename = createWalletPath(settings.wallet_path,settings.account_name)
        if(isIOS) {
            console.log("saving in ios: "+ edollarAccountsDir + new_wallet_filename)
            settings.wallet.store(edollarAccountsDir + new_wallet_filename);
        } else {
            console.log("saving in wizard: "+ new_wallet_filename)
            settings.wallet.store(new_wallet_filename);

        }



        // make sure temporary wallet files are deleted
        console.log("Removing temporary wallet: "+ settings.tmp_wallet_filename)
        oshelper.removeTemporaryWallet(settings.tmp_wallet_filename)

        // protecting wallet with password
        settings.wallet.setPassword(settings.wallet_password);

        // Store password in session to be able to use password protected functions (e.g show seed)
        appWindow.password = settings.wallet_password
        appWindow.walletPassword = settings.wallet_password

        // saving wallet_filename;
        settings['wallet_filename'] = new_wallet_filename;

        // persist settings
        appWindow.persistentSettings.language = settings.language
        appWindow.persistentSettings.locale   = settings.locale
        appWindow.persistentSettings.account_name = settings.account_name
        appWindow.persistentSettings.wallet_path = new_wallet_filename
        appWindow.persistentSettings.allow_background_mining = false //settings.allow_background_mining
        appWindow.persistentSettings.auto_donations_enabled = false //settings.auto_donations_enabled
        appWindow.persistentSettings.auto_donations_amount = false //settings.auto_donations_amount
        appWindow.persistentSettings.restore_height = (isNaN(settings.restore_height))? 0 : settings.restore_height
        appWindow.persistentSettings.is_recovering = (settings.is_recovering === undefined)? false : settings.is_recovering
    }

    // reading settings from persistent storage
    Component.onCompleted: {
        settings['allow_background_mining'] = appWindow.persistentSettings.allow_background_mining
        settings['auto_donations_enabled'] = appWindow.persistentSettings.auto_donations_enabled
        settings['auto_donations_amount'] = appWindow.persistentSettings.auto_donations_amount
        //set default language
        settings['language'] = "English (US)"
        settings['wallet_language'] = "English"
        settings['locale'] = "en_US"
        optionsPage.opacity = 1
        welcomePage.opacity = 0
        //currentPage = 1
    }

    MessageDialog {
        id: walletErrorDialog
        title: "Error"
        onAccepted: {
        }
    }

    WizardWelcome {
        id: welcomePage
//        Layout.bottomMargin: wizardBottomMargin
        Layout.topMargin: wizardTopMargin

    }

    WizardOptions {
        id: optionsPage
        Layout.bottomMargin: wizardBottomMargin
        Layout.topMargin: wizardTopMargin
        onCreateWalletClicked: wizard.openCreateWalletPage()
        onRecoveryWalletClicked: wizard.openRecoveryWalletPage()
        onOpenWalletClicked: wizard.openOpenWalletPage();
        onCreateViewOnlyWaletClicked: wizard.openCreateViewOnlyWalletPage();
    }

    WizardCreateWallet {
        id: createWalletPage
        Layout.bottomMargin: wizardBottomMargin
        Layout.topMargin: wizardTopMargin
        Layout.leftMargin: wizardLeftMargin
    }

    WizardCreateViewOnlyWallet {
        id: createViewOnlyWalletPage
        Layout.bottomMargin: wizardBottomMargin
        Layout.topMargin: wizardTopMargin
    }

    WizardRecoveryWallet {
        id: recoveryWalletPage
        Layout.bottomMargin: wizardBottomMargin
        Layout.topMargin: wizardTopMargin
        Layout.leftMargin: wizardLeftMargin
    }

    WizardPassword {
        id: passwordPage
        Layout.bottomMargin: wizardBottomMargin
        Layout.topMargin: wizardTopMargin
    }

    WizardDonation {
        id: donationPage
        Layout.bottomMargin: wizardBottomMargin
        Layout.topMargin: wizardTopMargin
    }

    WizardFinish {
        id: finishPage
        Layout.bottomMargin: wizardBottomMargin
        Layout.topMargin: wizardTopMargin
    }

    Rectangle {
        id: prevButton
        anchors.verticalCenter: wizard.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: isMobile ?  20 :  50
        anchors.bottomMargin: isMobile ?  20 :  50
        visible: parent.currentPage > 0

        width: 50; height: 50
        radius: 25
        color: prevArea.containsMouse ? "#3F51B5" : "#303F9F"

        Image {
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: -3
            source: "qrc:///images/prevPage.png"
        }

        MouseArea {
            id: prevArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: wizard.switchPage(false)
        }
    }

    Rectangle {
        id: nextButton
        anchors.verticalCenter: wizard.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 50
        anchors.bottomMargin: 50
        visible: parent.currentPage >= 1 && parent.currentPage < pages.length - 1
        width: 50; height: 50
        radius: 25
        color: enabled ? nextArea.containsMouse ? "#3F51B5" : "#303F9F" : "#DBDBDB"


        Image {
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: 3
            source: "qrc:///images/nextPage.png"
        }

        MouseArea {
            id: nextArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: wizard.switchPage(true)
        }
    }

    StandardButton {
        id: sendButton
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins:  (isMobile) ? 20 : 50
        text: qsTr("USE EDOLLAR")
        shadowReleasedColor: "#3F51B5"
        shadowPressedColor: "#303F9F"
        releasedColor: "#3F51B5"
        pressedColor: "#303F9F"
        visible: parent.paths[currentPath][currentPage] === finishPage
        onClicked: {
            wizard.applySettings();
            var walletFile =  wizard.createWalletPath(settings['wallet_path'], settings['account_name'])
            console.log("wallet path: " + walletFile)
            console.log("passwordWizard: " + settings['wallet_password'])
            walletManager.openWalletAsync(walletFile, settings['wallet_password'], appWindow.persistentSettings.testnet)
            wizard.useEdollarClicked();
        }
    }


//   Image {
//       anchors.right: parent.right
//       anchors.top: parent.top
//       anchors.rightMargin: 15
//       anchors.topMargin: 15
//       width: 24
//       height: 24
//       fillMode: Image.PreserveAspectFit
//       horizontalAlignment: Image.AlignRight
//       verticalAlignment: Image.AlignTop
//       //anchors.centerIn: parent
//       source: "qrc:/images/white/edollar-close-green.png"
//       opacity: 0.6

//       MouseArea {
//           id: createWalletArea
//           anchors.fill: parent
//           hoverEnabled: true
//           onClicked: {
//               console.log('click ...')
//               close()
//           }
//       }
//   }

}
