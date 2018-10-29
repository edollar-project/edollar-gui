import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0
import QtQuick.Window 2.2

import QtQuick.Controls.Styles 1.1
import QtQuick.Dialogs 1.2
import Qt.labs.settings 1.0

import edollarComponents.Wallet 1.0
import edollarComponents.PendingTransaction 1.0


import "components"
import "wizard"

import "common"
import "pages"
import "popups"
import "tabs"

import edollarComponents.Wallet 1.0
import edollarComponents.PendingTransaction 1.0

import "components"
import "wizard"

ApplicationWindow {
    id: appWindow
    visible: true
    objectName: "appWindow"
    title: 'Edollar Wallet'

    property int mWidth: Screen.desktopAvailableWidth < 900? Screen.desktopAvailableWidth : 900
    property int mHeight: Screen.desktopAvailableHeight < 680? Screen.desktopAvailableHeight: 680
    property bool fullySynced: false
    property bool isWalletOpened: false
    width: mWidth
    height: mHeight

    //Wallet App
    property var currentItem
    property bool whatIsEnable: false
    property bool ctrlPressed: false
    property bool rightPanelExpanded: false
    property bool osx: false
    property alias persistentSettings : persistentSettings
    property var currentWallet;
    property var transaction;
    property var transactionDescription;
    property alias password : passwordDialog.password
    property bool isNewWallet: false
    property int restoreHeight: 0
    property bool daemonSynced: false
    property int maxWindowHeight: (Screen.height < 900)? 720 : 800;
    property bool daemonRunning: false
    property alias toolTip: toolTip
    property string walletName
    property bool viewOnly: false
    property bool foundNewBlock: false
    property int timeToUnlock: 0
    property bool qrScannerEnabled: (typeof builtWithScanner != "undefined") && builtWithScanner
    property int blocksToSync: 1
    property var cameraUi
    property bool isMobile: false
    property var walletPassword
    readonly property string localDaemonAddress : !persistentSettings.testnet ? "localhost:33031" : "localhost:43031"
    property bool remoteNodeConnected: false

    //work arround to update wallet history if user close wallet when it's in pending
    property bool firstUpdateHistory: false
    property bool firedWalletConnected: false

    // true if wallet ever synchronized
    property bool walletInitialized : false
    property int hasPendingTxAtHeight : 0

    maximumWidth: appWindow.mWidth
    property bool isLandscape: width > height

    property bool showWizardCalled: false
    property bool createViewWalletCalled: false

    // Meterial design property
    // primary and accent properties:
    property variant primaryPalette: mainApp.primaryPalette(4)
    property color primaryLightColor: primaryPalette[0]
    property color primaryColor: primaryPalette[1]
    property color primaryDarkColor: primaryPalette[2]
    property color textOnPrimaryLight: primaryPalette[3]
    property color textOnPrimary: primaryPalette[4]
    property color textOnPrimaryDark: primaryPalette[5]
    property string iconOnPrimaryLightFolder: primaryPalette[6]
    property string iconOnPrimaryFolder: primaryPalette[7]
    property string iconOnPrimaryDarkFolder: primaryPalette[8]
    property variant accentPalette: mainApp.defaultAccentPalette()
    property color accentColor: accentPalette[0]
    property color textOnAccent: accentPalette[1]
    property string iconOnAccentFolder: accentPalette[2]
    Material.primary: primaryColor
    Material.accent: accentColor
    // theme Dark vs Light properties:
    property variant themePalette: mainApp.defaultThemePalette()
    property color dividerColor: themePalette[0]
    property color cardAndDialogBackground: themePalette[1]
    property real primaryTextOpacity: themePalette[2]
    property real secondaryTextOpacity: themePalette[3]
    property real dividerOpacity: themePalette[4]
    property real iconActiveOpacity: themePalette[5]
    property real iconInactiveOpacity: themePalette[6]
    property string iconFolder: themePalette[7]
    property int isDarkTheme: themePalette[8]
    property color flatButtonTextColor: themePalette[9]
    property color popupTextColor: themePalette[10]
    property real toolBarActiveOpacity: themePalette[11]
    property real toolBarInactiveOpacity: themePalette[12]
    // Material.dropShadowColor  OK for Light, but too dark for dark theme
    property color dropShadow: isDarkTheme? "#E4E4E4" : Material.dropShadowColor
    onIsDarkThemeChanged: {
        if(isDarkTheme == 1) {
            Material.theme = Material.Dark
        } else {
            Material.theme = Material.Light
        }
    }
    // font sizes - defaults from Google Material Design Guide
    property int fontSizeDisplay4: 112
    property int fontSizeDisplay3: 56
    property int fontSizeDisplay2: 45
    property int fontSizeDisplay1: 34
    property int fontSizeHeadline: 24
    property int fontSizeTitle: 20
    property int fontSizeSubheading: 16
    property int fontSizeBodyAndButton: 14 // is Default
    property int fontSizeCaption: 12
    // fonts are grouped into primary and secondary with different Opacity
    // to make it easier to get the right property,
    // here's the opacity per size:
    property real opacityDisplay4: secondaryTextOpacity
    property real opacityDisplay3: secondaryTextOpacity
    property real opacityDisplay2: secondaryTextOpacity
    property real opacityDisplay1: secondaryTextOpacity
    property real opacityHeadline: primaryTextOpacity
    property real opacityTitle: primaryTextOpacity
    property real opacitySubheading: primaryTextOpacity
    // body can be both: primary or secondary text
    property real opacityBodyAndButton: primaryTextOpacity
    property real opacityBodySecondary: secondaryTextOpacity
    property real opacityCaption: secondaryTextOpacity
    //

    // TabBar properties
    property string titleAndTabBarSource: "tabs/TitleWithIconTextTabBar.qml"
    property bool tabBarIsFixed: true
    property bool tabBarInsideTitleBar: true

    property var tabButtonModel: [          {"name": "Dashboard", "icon": "edollar-home.png"},
                                            {"name": "Send", "icon": "edollar-send.png"},
                                            {"name": "Receive", "icon": "edollar-receive.png"},
                                            {"name": "History", "icon": "edollar-history.png"},
                                            {"name": "Setting", "icon": "edollar-setting.png"}]

    property string walletAddress: ""
//    property var viewKey: ""
//    property var mainAddress: ""
//    property int walletHeight: 0
//    property var acountName: ""

    //signal
    signal walletConnected()
    signal walletClosed()
    signal transferCompleted()
    signal viewOnlyWalletRequested(string accountName, string viewKey, string mainAddress, int height)
    signal historyChanged() //work-around, sometime onModelChanged does not work

    header: isLandscape? null : headerTitleBar

    // loader alias
    property alias dashboardLoaderItem: dashboardLoader.item

    Loader {
        id: headerTitleBar
        visible: !isLandscape
        active: !isLandscape
        source: titleAndTabBarSource
        onLoaded: {
            if(item) {
                item.currentIndex = navPane.currentIndex
                item.text = qsTr("Edollar Wallet")
            }
        }
    }
    // in LANDSCAPE header is null and we have a floating TitleBar
    // hint: TitleBar shadow not visible in Landscape
    // reason: TabBar must be defined inside ToolBar
    // but they're defined in column layout - haven't redesigned for this example
    // only wanted to demonstrate HowTo use fix and floating Titles
    Loader {
        id: titleBarFloating
        visible: isLandscape
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        active: isLandscape
        source: titleAndTabBarSource
        onLoaded: {
            if(item) {
                item.currentIndex = navPane.currentIndex
                item.text = qsTr("Edollar Wallet")
            }
        }
    }

    SwipeView {
        id: navPane
        focus: true
        // anchors.fill: parent
        anchors.top: isLandscape? titleBarFloating.bottom : parent.top
        anchors.topMargin: isLandscape? 6 : 0
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        currentIndex: 0
        // currentIndex is the NEXT index swiped to
        onCurrentIndexChanged: {
            if(isLandscape) {
                titleBarFloating.item.currentIndex = currentIndex
            } else {
                headerTitleBar.item.currentIndex = currentIndex
            }
            switch(currentIndex) {
            case 1:
                pageReceiveLoader.active = true
                break;
            case 2:
                pageReceiveLoader.active = true
                pageHistoryLoader.active = true
                break;
            case 3:
                pageReceiveLoader.active = true
                pageHistoryLoader.active = true
                pageSettingLoader.active = true
                break;
            case 4:
                pageHistoryLoader.active = true
                pageSettingLoader.active = true
                break;
            }
        }


        function goToPage(pageIndex) {
            if(pageIndex === navPane.currentIndex) {
                // it's the current page
                return
            }
            if(pageIndex > 4 || pageIndex < 0) {
                return
            }
            navPane.currentIndex = pageIndex
        } // goToPage
        // Page 1 and 2 preloaded to be able to swipe
        // other pages will be lazy loaded first time they're needed
        Loader {
            // index 0
            id: dashboardLoader
            active: true
            source: "pages/Dashboard.qml"
            onLoaded: console.log("Loaded dashboard ...")
        }
        Loader {
            // index 1
            id: pageTransferLoader
            active: true
            source: "pages/Transfer.qml"
        }
        Loader {
            // Receiver page
            id: pageReceiveLoader
            active: true
            source: "pages/Receive.qml"
        }
        Loader {
            // index 3
            id: pageHistoryLoader
            active: true
            source: "pages/History.qml"
        }
        Loader {
            // index 4
            id: pageSettingLoader
            active: true
            source: "pages/Setting.qml"
        }

    } // navPane

    function switchPrimaryPalette(paletteIndex) {
        primaryPalette = mainApp.primaryPalette(paletteIndex)
        persistentSettings.themeColor = paletteIndex
    }
    function switchAccentPalette(paletteIndex) {
        accentPalette = mainApp.accentPalette(paletteIndex)
    }

    // we can loose the focus if Menu or Popup is opened
    function resetFocus() {
        navPane.focus = true
    }

    //
    PopupPalette {
        id: popup
        onAboutToHide: {
            resetFocus()
        }
    }

    //update wallet balance
    function updateWalletBalance(balance, unlockedBalance) {
       if (dashboardLoaderItem) {
           console.log("update wallet ...")
           console.log("balance = " + balance)
           dashboardLoaderItem.balanceText = balance + ' EDL'
           dashboardLoaderItem.unlockedBalanceText = unlockedBalance + ' EDL'
       } else {
          console.log("Dashboard loader is null")
       }
    }

    function updateConnected(isConnected) {
        console.log("Connect to daemon: " + isConnected)
        if (dashboardLoaderItem) {
            dashboardLoaderItem.networkStatus.connected = isConnected
        }
    }


    function showInfo(info) {
        popupInfo.text = info
        popupInfo.buttonText = qsTr("OK")
        popupInfo.open()
    }

    // Unfortunately no SIGNAL if end or beginning reached from SWIPE GESTURE
    // so at the moment user gets no visual feedback
    // TODO Bugreport
    PopupInfo {
        id: popupInfo
        onAboutToHide: {
            popupInfo.stopTimer()
            resetFocus()
        }
    } // popupInfo




    //signal connect main app to page

    function altKeyReleased() { ctrlPressed = false; }

    function showPageRequest(page) {

    }

    function sequencePressed(obj, seq) {
        //topPanel.selectItem(.state)
    }

    function sequenceReleased(obj, seq) {
        if(seq === "Ctrl")
            ctrlPressed = false
    }

    function mousePressed(obj, mouseX, mouseY) {}
    function mouseReleased(obj, mouseX, mouseY) {}

    function loadPage(page) {

    }

    function openWalletFromFile(){
        persistentSettings.restore_height = 0
        restoreHeight = 0;
        persistentSettings.is_recovering = false
        appWindow.password = ""
        fileDialog.open();
    }

    function initialize() {
        console.log("initializing..")
        walletInitialized = false;

        // Use stored log level
        if (persistentSettings.logLevel == 5)
          walletManager.setLogCategories(persistentSettings.logCategories)
        else
          walletManager.setLogLevel(persistentSettings.logLevel)

        // setup language
        var locale = persistentSettings.locale
        if (locale !== "") {
            translationManager.setLanguage(locale.split("_")[0]);
        }

        walletManager.setDaemonAddress(persistentSettings.daemon_address)
        // wallet already opened with wizard, we just need to initialize it
        if (typeof wizard.settings['wallet'] !== 'undefined') {
           console.log("using wizard wallet ...")
//            //Set restoreHeight
//            if(persistentSettings.restore_height > 0){
//                // We store restore height in own variable for performance reasons.
//                restoreHeight = persistentSettings.restore_height
//            }

//            connectWallet(wizard.settings['wallet'])

 //           isNewWallet = true
            // We don't need the wizard wallet any more - delete to avoid conflict with daemon adress change
//            delete wizard.settings['wallet']
        }  else {
            var wallet_path = walletPath();
            if(isIOS)
                wallet_path = edollarAccountsDir + wallet_path;
            // console.log("opening wallet at: ", wallet_path, "with password: ", appWindow.password);
            console.log("opening wallet at: ", wallet_path, ", testnet: ", persistentSettings.testnet);
            walletManager.openWalletAsync(wallet_path, appWindow.password,
                                              persistentSettings.testnet);
        }

    }

    function closeWallet() {
        // Disconnect all listeners
        if (typeof currentWallet !== "undefined" && currentWallet !== null) {
            currentWallet.refreshed.disconnect(onWalletRefresh)
            currentWallet.updated.disconnect(onWalletUpdate)
            currentWallet.newBlock.disconnect(onWalletNewBlock)
            currentWallet.moneySpent.disconnect(onWalletMoneySent)
            currentWallet.moneyReceived.disconnect(onWalletMoneyReceived)
            currentWallet.unconfirmedMoneyReceived.disconnect(onWalletUnconfirmedMoneyReceived)
            currentWallet.transactionCreated.disconnect(onTransactionCreated)
            currentWallet.connectionStatusChanged.disconnect(onWalletConnectionStatusChanged)
        }
        //notify other components
        walletClosed()

        currentWallet = undefined;
        if (isIOS) {
            console.log("closing sync - ios")
            walletManager.closeWallet();
        } else
            walletManager.closeWalletAsync();
    }

    function connectWallet(wallet) {
        console.log("connect wallet ...")
        currentWallet = wallet
        walletName = usefulName(wallet.path)
        updateSyncing(false)

        viewOnly = currentWallet.viewOnly;
        console.log('viewOnly ', viewOnly? 'true': 'false')

        // New wallets saves the testnet flag in keys file.
        if(persistentSettings.testnet != currentWallet.testnet) {
            console.log("Using testnet flag from keys file")
            persistentSettings.testnet = currentWallet.testnet;
        }

        // connect handlers
        currentWallet.refreshed.connect(onWalletRefresh)
        currentWallet.updated.connect(onWalletUpdate)
        currentWallet.newBlock.connect(onWalletNewBlock)
        currentWallet.moneySpent.connect(onWalletMoneySent)
        currentWallet.moneyReceived.connect(onWalletMoneyReceived)
        currentWallet.unconfirmedMoneyReceived.connect(onWalletUnconfirmedMoneyReceived)
        currentWallet.transactionCreated.connect(onTransactionCreated)
        currentWallet.connectionStatusChanged.connect(onWalletConnectionStatusChanged)

        console.log("initializing with daemon address: ", persistentSettings.daemon_address)
        console.log("Recovering from seed: ", persistentSettings.is_recovering)
        console.log("restore Height", persistentSettings.restore_height)

        // Use saved daemon rpc login settings
        currentWallet.setDaemonLogin(persistentSettings.daemonUsername, persistentSettings.daemonPassword);

        currentWallet.initAsync(persistentSettings.daemon_address, 0, persistentSettings.is_recovering, persistentSettings.restore_height);

    }

    function walletPath() {
        var wallet_path = persistentSettings.wallet_path
        return wallet_path;
    }

    function usefulName(path) {
        // arbitrary "short enough" limit
        if (path.length < 32)
            return path
        return path.replace(/.*[\/\\]/, '').replace(/\.keys$/, '')
    }


    function onWalletConnectionStatusChanged(status) {
        console.log("Wallet connection status changed " + status)

        // If wallet isnt connected and no daemon is running - Ask
        if(isDaemonLocal() && !walletInitialized && status === Wallet.ConnectionStatus_Disconnected && !daemonManager.running(persistentSettings.testnet)){
            //console.log('persistentSettings.useRemoteNode -- 0', persistentSettings.useRemoteNode)
            daemonManagerDialog.open();
        } else if(!remoteNodeConnected) {
            console.log('daemonRunning')
            daemonRunning = true
            dashboardLoaderItem.networkStatus.connected = true
        }

        // initialize transaction history once wallet is initialized first time;
        if (!walletInitialized && status !== Wallet.ConnectionStatus_Disconnected) {
            //mainPage.updateConnected(status)
        }
        if (!walletInitialized) {
            currentWallet.history.refresh(currentWallet.currentSubaddressAccount)
            walletInitialized = true
        }
     }

    function onWalletOpened(wallet) {
        walletName = usefulName(wallet.path)
        console.log(">>> wallet opened: " + wallet)
        if (wallet.status !== Wallet.Status_Ok) {
            if (appWindow.password === '') {
                console.error("Error opening wallet with empty password: ", wallet.errorString);
                console.log("closing wallet async : " + wallet.address)
                closeWallet();
                // try to open wallet with password;
                passwordDialog.open(walletName);
            } else {
                // opening with password but password doesn't match
                console.error("Error opening wallet with password: ", wallet.errorString);

                informationPopup.title  = qsTr("Error") + translationManager.emptyString;
                informationPopup.text = qsTr("Couldn't open wallet: ") + wallet.errorString;
                informationPopup.icon = StandardIcon.Critical
                console.log("closing wallet async : " + wallet.address)
                closeWallet();
                informationPopup.open()
                informationPopup.onCloseCallback = function() {
                    passwordDialog.open(walletName)
                }
            }
            return;
        }

        // wallet opened successfully, subscribing for wallet updates
        isWalletOpened = true
        connectWallet(wallet)
    }


    function onWalletClosed(walletAddress) {
        console.log(">>> wallet closed: " + walletAddress)
        isWalletOpened = false
        hideProcessingSplash()
        if (showWizardCalled) {
            console.log('showWizard')
            walletInitialized = false;
            currentWallet = undefined;
            wizard.restart();
            rootItem.state = "wizard"
            wizard.visible = true
            appWindow.visible = true
            firedWalletConnected = false
            showWizardCalled = false
        }
        if (createViewWalletCalled) {
            //wizard.restart();
            rootItem.state = "wizard"
            appWindow.visible = true
            firedWalletConnected = false

            wizard.visible = true
            wizard.openCreateViewOnlyWalletPage()
            createViewWalletCalled = false
        }
    }

    function onWalletUpdate() {
        console.log(">>> wallet updated ...")
        if (currentWallet) {
            var unlockedBalanceText = walletManager.displayAmount(currentWallet.unlockedBalance(currentWallet.currentSubaddressAccount))
            var balanceText = walletManager.displayAmount(currentWallet.balance(currentWallet.currentSubaddressAccount))
            console.log("lockBalance: " + balanceText + " unlock: " + unlockedBalanceText)
            //mainPage.updateWalletBalance(balanceText, unlockedBalanceText)
            if (dashboardLoaderItem) {
                dashboardLoaderItem.balanceText = balanceText
                dashboardLoaderItem.unlockedBalanceText = unlockedBalanceText
            }
        }
    }

    function onWalletRefresh() {
        console.log(">>> wallet refreshed")
        currentWallet.history.refresh(currentWallet.currentSubaddressAccount)
        console.log('History count: ', currentWallet.historyModel.rowCount())
        historyChanged()
        //hide flash
        hideProcessingSplash()
        onWalletUpdate();
        //TODO: update network hashrate, block height
        // Check daemon status
        var dCurrentBlock = currentWallet.daemonBlockChainHeight();
        var dTargetBlock = currentWallet.daemonBlockChainTargetHeight();
        console.log('dCurrentBlock: ', dCurrentBlock, ' dTargetBlock', dTargetBlock)
        // Daemon fully synced
        // TODO: implement onDaemonSynced or similar in wallet API and don't start refresh thread before daemon is synced
        // targetBlock = currentBlock = 1 before network connection is established.
        daemonSynced = dCurrentBlock >= dTargetBlock && dTargetBlock > 1
        console.log('currentBlock: ', dCurrentBlock, ' targetBlock:', dTargetBlock, ' daemonSynced: ', daemonSynced)
        dashboardLoaderItem.progressBar.updateProgress(dCurrentBlock, dTargetBlock)

        // Refresh is succesfull if blockchain height > 1
        if (currentWallet.blockChainHeight() > 1){
            //console.log('>>>>>> Refesh history ...')
            //currentWallet.history.refresh(currentWallet.currentSubaddressAccount);

            // Save new wallet after first refresh
            // Wallet is nomrmally saved to disk on app exit. This prevents rescan from block 0 after app crash
            if(isNewWallet){
                console.log("Saving wallet after first refresh");
                currentWallet.store()
                isNewWallet = false
            }

            // recovering from seed is finished after first refresh
            if(persistentSettings.is_recovering) {
                persistentSettings.is_recovering = false
            }
        }
        //wallet really ready, fire this signal once
        if (!firedWalletConnected) {
            firedWalletConnected = true
            walletConnected()
        }

        if (remoteNodeConnected) {
            dashboardLoaderItem.networkStatus.connected = true
            dashboardLoaderItem.infoCurrenHeight ='Wallet synced with remote node'
            dashboardLoaderItem.infoNetHash = ''
        }
    }

    function startDaemon(flags){
        // Pause refresh while starting daemon

        currentWallet.pauseRefresh();

        //disconnect remote node
        if (remoteNodeConnected) {
            disconnectRemoteNode()
        }

        //add peer to flag
        var peerFlag = ''
        var peers = appWindow.persistentSettings.peers
        var nodeAddress = peers.split(";")
        for (var i = 0; i < nodeAddress.length; ++i) {
            if (nodeAddress[i].length < 9) continue
            peerFlag += ' --add-peer ' + nodeAddress[i]
        }
        console.log('flag ', peerFlag)
        appWindow.showProcessingSplash(qsTr("Waiting for daemon to start..."))
        daemonManager.start(flags + peerFlag, persistentSettings.testnet, persistentSettings.blockchainDataDir);
        persistentSettings.daemonFlags = flags
    }

    function stopDaemon(){
        appWindow.showProcessingSplash(qsTr("Waiting for daemon to stop..."))
        daemonManager.stop(persistentSettings.testnet);
    }

    function onDaemonStarted(){
        console.log("daemon started");
        daemonRunning = true;
        hideProcessingSplash();
        currentWallet.connected(true);
        // resume refresh
        currentWallet.startRefresh();
        dashboardLoaderItem.networkStatus.connected = true
        dashboardLoaderItem.infoCurrenHeight ='Wallet is synchronizing with local node'
        dashboardLoaderItem.infoNetHash = ''

    }
    function onDaemonStopped(){
        console.log("daemon stopped");
        hideProcessingSplash();
        daemonRunning = false;
        currentWallet.connected(true);
        dashboardLoaderItem.networkStatus.connected = false
    }

    function onDaemonStartFailure(){
        console.log("daemon start failed");
        hideProcessingSplash();
        // resume refresh
        currentWallet.startRefresh();
        daemonRunning = false;
        informationPopup.title = qsTr("Daemon failed to start") + translationManager.emptyString;
        informationPopup.text  = qsTr("Please check your wallet and daemon log for errors. You can also try to start %1 manually.").arg((isWindows)? "edollard.exe" : "edollard")
        informationPopup.icon  = StandardIcon.Critical
        informationPopup.onCloseCallback = null
        informationPopup.open();
    }

    function connectRemoteNode(username, password, address) {
        if (daemonRunning) {
            stopDaemon()
        }
        if (address.length < 8) return
        console.log("connecting remote node, username=", username, ' password=', password, ' address=', address);
        persistentSettings.useRemoteNode = true;
        currentWallet.setDaemonLogin(username, password);
        currentWallet.initAsync(address, false, 50000);
        remoteNodeConnected = true;
        persistentSettings.remoteAddress = address
        persistentSettings.remotePassword = password
        persistentSettings.remoteUserName = username
        dashboardLoaderItem.infoCurrenHeight ='Wallet is synchronizing with remote node'
        dashboardLoaderItem.infoNetHash = ''
    }

    function disconnectRemoteNode() {
        console.log("disconnecting remote node");
        persistentSettings.useRemoteNode = false;
        //currentDaemonAddress = localDaemonAddress
        currentWallet.initAsync(localDaemonAddress);
        remoteNodeConnected = false;
        dashboardLoaderItem.networkStatus.connected = false
        dashboardLoaderItem.progressBar.connected = false
//        persistentSettings.remoteAddress = ""
//        persistentSettings.remotePassword = ""
//        persistentSettings.remoteUserName = ""
    }

    function onWalletNewBlock(blockHeight, targetHeight) {

    }

    function onWalletMoneyReceived(txId, amount) {
        console.log('======Receive money=====', txId, '  ', amount)
        // refresh transaction history here
        currentWallet.refresh()
        currentWallet.history.refresh(currentWallet.currentSubaddressAccount) // this will refresh model
        historyChanged()
    }

    function onWalletUnconfirmedMoneyReceived(txId, amount) {
        // refresh history
        console.log("unconfirmed money found ", txId, ' ', amount)
        currentWallet.history.refresh(currentWallet.currentSubaddressAccount)
        historyChanged()
    }

    function onWalletMoneySent(txId, amount) {
        // refresh transaction history here
        console.log("onWalletMoneySent  ", txId, ' ', amount)
        currentWallet.refresh()
        currentWallet.history.refresh(currentWallet.currentSubaddressAccount) // this will refresh model
        historyChanged()
    }

    function walletsFound() {
        if (persistentSettings.wallet_path.length > 0) {
            if(isIOS)
                return walletManager.walletExists(edollarAccountsDir + persistentSettings.wallet_path);
            else
                return walletManager.walletExists(persistentSettings.wallet_path);
        }
        return false;
    }

    function onTransactionCreated(pendingTransaction,address,paymentId,mixinCount){
        console.log("Transaction created");
        hideProcessingSplash();
        transaction = pendingTransaction;
        // validate address;
        if (transaction.status !== PendingTransaction.Status_Ok) {
            console.error("Can't create transaction: ", transaction.errorString);
            informationPopup.title = qsTr("Error") + translationManager.emptyString;
            if (currentWallet.connected() == Wallet.ConnectionStatus_WrongVersion)
                informationPopup.text  = qsTr("Can't create transaction: Wrong daemon version: ") + transaction.errorString
            else
                informationPopup.text  = qsTr("Can't create transaction: ") + transaction.errorString
            informationPopup.icon  = StandardIcon.Critical
            informationPopup.onCloseCallback = null
            informationPopup.open();
            // deleting transaction object, we don't want memleaks
            currentWallet.disposeTransaction(transaction);

        } else if (transaction.txCount == 0) {
            informationPopup.title = qsTr("Error") + translationManager.emptyString
            informationPopup.text  = qsTr("No unmixable outputs to sweep") + translationManager.emptyString
            informationPopup.icon = StandardIcon.Information
            informationPopup.onCloseCallback = null
            informationPopup.open()
            // deleting transaction object, we don't want memleaks
            currentWallet.disposeTransaction(transaction);
        } else {
            console.log("Transaction created, amount: " + walletManager.displayAmount(transaction.amount)
                    + ", fee: " + walletManager.displayAmount(transaction.fee));

            // here we show confirmation popup;

            transactionConfirmationPopup.title = qsTr("Confirmation") + translationManager.emptyString
            transactionConfirmationPopup.text  = qsTr("Please confirm transaction:\n")
                        + (address === "" ? "" : (qsTr("\nAddress: ") + address))
                        + (paymentId === "" ? "" : (qsTr("\nPayment ID: ") + paymentId))
                        + qsTr("\n\nAmount: ") + walletManager.displayAmount(transaction.amount)
                        + qsTr("\nFee: ") + walletManager.displayAmount(transaction.fee)
                        + qsTr("\n\nRingsize: ") + (mixinCount + 1)
                        + qsTr("\n\Number of transactions: ") + transaction.txCount
                        + (transactionDescription === "" ? "" : (qsTr("\n\nDescription: ") + transactionDescription))
                        + translationManager.emptyString
            transactionConfirmationPopup.icon = StandardIcon.Question
            transactionConfirmationPopup.open()
        }
    }


    // called on "transfer"
    function handlePayment(address, amount, mixinCount, priority, description, createFile) {
        console.log("Creating transaction: ")
        console.log("\taddress: ", address,
                    ", amount: ", amount,
                    ", mixins: ", mixinCount,
                    ", priority: ", priority,
                    ", description: ", description);

        showProcessingSplash("Creating transaction");

        transactionDescription = description;

        // validate amount;
        if (amount !== "(all)") {
            var amountxmr = walletManager.amountFromString(amount);
            console.log("integer amount: ", amountxmr);
            console.log("integer unlocked",currentWallet.unlockedBalance)
            if (amountxmr <= 0) {
                hideProcessingSplash()
                informationPopup.title = qsTr("Error") + translationManager.emptyString;
                informationPopup.text  = qsTr("Amount is wrong: expected number from %1 to %2")
                        .arg(walletManager.displayAmount(0))
                        .arg(walletManager.maximumAllowedAmountAsSting())
                        + translationManager.emptyString

                informationPopup.icon  = StandardIcon.Critical
                informationPopup.onCloseCallback = null
                informationPopup.open()
                return;
            } else if (amountxmr > currentWallet.unlockedBalance) {
                hideProcessingSplash()
                informationPopup.title = qsTr("Error") + translationManager.emptyString;
                informationPopup.text  = qsTr("Insufficient funds. Unlocked balance: %1")
                        .arg(walletManager.displayAmount(currentWallet.unlockedBalance))
                        + translationManager.emptyString

                informationPopup.icon  = StandardIcon.Critical
                informationPopup.onCloseCallback = null
                informationPopup.open()
                return;
            }
        }

        if (amount === "(all)")
            currentWallet.createTransactionAllAsync(address, "", mixinCount, priority);
        else
            currentWallet.createTransactionAsync(address, "", amountxmr, mixinCount, priority);
    }

    // called on "transferMany"
    function handlePaymentMany(dest, mixinCount, priority, description, createFile) {
        console.log("Creating transaction ... ")

        showProcessingSplash("Creating transaction");

        transactionDescription = description;

        var destination = {}
        var totalSpendAmount = 0
        for (var d in dest) {
            console.log(d.address, ' === ', d.amount)
        }
        currentWallet.createTransactionManyAsync(dest, mixinCount, priority);
    }

    function daemonFullySynced() {
        if (!fullySynced && isWalletOpened) {
            console.log('Daemon fully synced, refresh wallet')
            fullySynced = true
            showProcessingSplash("Refreshing your wallet, please wait ...")
        }
    }

    //Choose where to save transaction
    FileDialog {
        id: saveTxDialog
        title: "Please choose a location"
        folder: "file://" + edollarAccountsDir
        selectExisting: false;

        onAccepted: {
            handleTransactionConfirmed()
        }
        onRejected: {
            // do nothing

        }

    }


    function handleSweepUnmixable() {
        console.log("Creating transaction: ")

        transaction = currentWallet.createSweepUnmixableTransaction();
        if (transaction.status !== PendingTransaction.Status_Ok) {
            console.error("Can't create transaction: ", transaction.errorString);
            informationPopup.title = qsTr("Error") + translationManager.emptyString;
            informationPopup.text  = qsTr("Can't create transaction: ") + transaction.errorString
            informationPopup.icon  = StandardIcon.Critical
            informationPopup.onCloseCallback = null
            informationPopup.open();
            // deleting transaction object, we don't want memleaks
            currentWallet.disposeTransaction(transaction);

        } else if (transaction.txCount == 0) {
            informationPopup.title = qsTr("Error") + translationManager.emptyString
            informationPopup.text  = qsTr("No unmixable outputs to sweep") + translationManager.emptyString
            informationPopup.icon = StandardIcon.Information
            informationPopup.onCloseCallback = null
            informationPopup.open()
            // deleting transaction object, we don't want memleaks
            currentWallet.disposeTransaction(transaction);
        } else {
            console.log("Transaction created, amount: " + walletManager.displayAmount(transaction.amount)
                    + ", fee: " + walletManager.displayAmount(transaction.fee));

            // here we show confirmation popup;

            transactionConfirmationPopup.title = qsTr("Confirmation") + translationManager.emptyString
            transactionConfirmationPopup.text  = qsTr("Please confirm transaction:\n")
                        + qsTr("\n\nAmount: ") + walletManager.displayAmount(transaction.amount)
                        + qsTr("\nFee: ") + walletManager.displayAmount(transaction.fee)
                        + translationManager.emptyString
            transactionConfirmationPopup.icon = StandardIcon.Question
            transactionConfirmationPopup.open()
            // committing transaction
        }
    }

    // called after user confirms transaction
    function handleTransactionConfirmed(fileName) {
        // grab transaction.txid before commit, since it clears it.
        // we actually need to copy it, because QML will incredibly
        // call the function multiple times when the variable is used
        // after commit, where it returns another result...
        // Of course, this loop is also calling the function multiple
        // times, but at least with the same result.
        var txid = [], txid_org = transaction.txid, txid_text = ""
        for (var i = 0; i < txid_org.length; ++i)
          txid[i] = txid_org[i]

        // View only wallet - we save the tx
        if(viewOnly && saveTxDialog.fileUrl){
            // No file specified - abort
            if(!saveTxDialog.fileUrl) {
                currentWallet.disposeTransaction(transaction)
                return;
            }

            var path = walletManager.urlToLocalPath(saveTxDialog.fileUrl)

            // Store to file
            transaction.setFilename(path);
        }

        if (!transaction.commit()) {
            console.log("Error committing transaction: " + transaction.errorString);
            informationPopup.title = qsTr("Error") + translationManager.emptyString
            informationPopup.text  = qsTr("Couldn't send the money: ") + transaction.errorString
            informationPopup.icon  = StandardIcon.Critical
        } else {
            informationPopup.title = qsTr("Information") + translationManager.emptyString
            for (var i = 0; i < txid.length; ++i) {
                if (txid_text.length > 0)
                    txid_text += ", "
                txid_text += txid[i]
            }
            informationPopup.text  = (viewOnly)? qsTr("Transaction saved to file: %1").arg(path) : qsTr("Money sent successfully: %1 transaction(s) ").arg(txid.length) + txid_text + translationManager.emptyString
            informationPopup.icon  = StandardIcon.Information
            if (transactionDescription.length > 0) {
                for (var i = 0; i < txid.length; ++i)
                  currentWallet.setUserNote(txid[i], transactionDescription);
            }

        }
        informationPopup.onCloseCallback = null
        informationPopup.open()
        currentWallet.refresh()
        currentWallet.disposeTransaction(transaction)
        currentWallet.store();
        transferCompleted()
        //historyChanged()
    }

    // called on "checkPayment"
    function handleCheckPayment(address, txid, txkey) {
        console.log("Checking payment: ")
        console.log("\taddress: ", address,
                    ", txid: ", txid,
                    ", txkey: ", txkey);

        var result = walletManager.checkPayment(address, txid, txkey, persistentSettings.daemon_address);
        var results = result.split("|");
        if (results.length < 4) {
            informationPopup.title  = qsTr("Error") + translationManager.emptyString;
            informationPopup.text = "internal error";
            informationPopup.icon = StandardIcon.Critical
            informationPopup.onCloseCallback = null
            informationPopup.open()
            return
        }
        var success = results[0] == "true";
        var received = results[1]
        var height = results[2]
        var error = results[3]
        if (success) {
            informationPopup.title  = qsTr("Payment check") + translationManager.emptyString;
            informationPopup.icon = StandardIcon.Information
            if (received > 0) {
                received = received / 1e12
                if (height == 0) {
                    informationPopup.text = qsTr("This address received %1 edollar, but the transaction is not yet mined").arg(received);
                }
                else {
                    var dCurrentBlock = currentWallet.daemonBlockChainHeight();
                    var confirmations = dCurrentBlock - height
                    informationPopup.text = qsTr("This address received %1 edollar, with %2 confirmation(s).").arg(received).arg(confirmations);
                }
            }
            else {
                informationPopup.text = qsTr("This address received nothing");
            }
        }
        else {
            informationPopup.title  = qsTr("Error") + translationManager.emptyString;
            informationPopup.text = error;
            informationPopup.icon = StandardIcon.Critical
        }
        informationPopup.open()
    }

    function updateSyncing(syncing) {
        return
    }

    // blocks UI if wallet can't be opened or no connection to the daemon
    function enableUI(enable) {

    }

    function showProcessingSplash(message) {
        console.log("Displaying processing splash")
        if (typeof message != 'undefined') {
            splash.messageText = message
            splash.heightProgressText = ""
        }
        splash.show()
    }

    function hideProcessingSplash() {
        console.log("Hiding processing splash")
        splash.close()
    }

    // close wallet and show wizard
    function showWizard(){
        console.log('showWizard')
        walletInitialized = false;
        closeWallet();
        currentWallet = undefined;
        wizard.restart();
        rootItem.state = "wizard"
        wizard.visible = true
        appWindow.visible = true
        firedWalletConnected = false
    }

    function closeCurrentWallet() {
        showProcessingSplash(qsTr("Closing current wallet ..."))
        walletInitialized = false
        showWizardCalled = true
        closeWallet()
    }

    function createViewOnlyWallet() {
        console.log('createViewWallet')
        createViewWalletCalled = true
        var accountName = walletName + '_viewOnly'
        var viewKey = currentWallet.secretViewKey
        var mainAddress = currentWallet.address(currentWallet.currentSubaddressAccount, 0)
        var walletHeight = currentWallet.walletCreationHeight

        viewOnlyWalletRequested(accountName, viewKey, mainAddress, walletHeight)

        showProcessingSplash(qsTr("Closing current wallet ..."))
        walletInitialized = false;
        closeWallet();
        currentWallet = undefined;


    }

    function hideMenu() {
        goToBasicAnimation.start();
        console.log(appWindow.width)
    }

    function showMenu() {
        goToProAnimation.start();
        console.log(appWindow.width)
    }

    color: "#FFFFFF"
    onWidthChanged: x -= 0

    Component.onCompleted: {
        console.log('mainApp>> page completed')
        x = (Screen.width - width) / 2
        y = (Screen.height - maxWindowHeight) / 2
        //
        walletManager.walletOpened.connect(onWalletOpened);
        walletManager.walletClosed.connect(onWalletClosed);
        walletManager.checkUpdatesComplete.connect(onWalletCheckUpdatesComplete);

        if(typeof daemonManager != "undefined") {
            daemonManager.daemonStarted.connect(onDaemonStarted);
            daemonManager.daemonStartFailure.connect(onDaemonStartFailure);
            daemonManager.daemonStopped.connect(onDaemonStopped);
        }



        // Connect app exit to qml window exit handling
        mainApp.closing.connect(appWindow.close);

        if( appWindow.qrScannerEnabled ){
            console.log("qrScannerEnabled : load component QRCodeScanner");
            var component = Qt.createComponent("components/QRCodeScanner.qml");
            if (component.status == Component.Ready) {
                console.log("Camera component ready");
                cameraUi = component.createObject(appWindow);
            } else {
                console.log("component not READY !!!");
                appWindow.qrScannerEnabled = false;
            }
        } else console.log("qrScannerEnabled disabled");

        if(!walletsFound()) {
            rootItem.state = "wizard"
        } else {
            rootItem.state = "normal"
                initialize(persistentSettings);
        }

        checkUpdates();

        //restore default theme
        switchPrimaryPalette(persistentSettings.themeColor)

        console.log('persistentSettings.useRemoteNode ', persistentSettings.useRemoteNode)

    }


    Settings {
        id: persistentSettings
        //visible: false
        property string language
        property string locale: "en_US"
        property string account_name
        property string wallet_path
        property bool   auto_donations_enabled : false
        property int    auto_donations_amount : 50
        property bool   allow_background_mining : false
        property bool   miningIgnoreBattery : true
        property bool   testnet: false
        property string daemon_address: testnet ? "localhost:43031" : "localhost:33031"
        property string payment_id
        property int    restore_height : 0
        property bool   is_recovering : false
        property bool   customDecorations : true
        property string daemonFlags
        property int logLevel: 0
        property string logCategories: ""
        property string daemonUsername: ""
        property string daemonPassword: ""
        property bool transferShowAdvanced: false
        property string blockchainDataDir: ""
        property string peers: ""
        property bool useRemoteNode: false
        property string remoteUserName: ""
        property string remotePassword: ""
        property string remoteAddress: ""
        property int themeColor: 4
    }

    // Information dialog
    StandardDialog {
        // dynamically change onclose handler
        property var onCloseCallback
        id: informationPopup
        cancelVisible: false
        onAccepted:  {
            if (onCloseCallback) {
                onCloseCallback()
            }
        }
    }

    // Confrirmation aka question dialog
    StandardDialog {
        id: transactionConfirmationPopup
        onAccepted: {
            close();
            transactionConfirmationPasswordDialog.onAcceptedCallback = function() {
                if(appWindow.password === transactionConfirmationPasswordDialog.password){
                    // Save transaction to file if view only wallet
                    if(viewOnly) {
                        saveTxDialog.open();
                    } else {
                        handleTransactionConfirmed()
                    }
                } else {
                    informationPopup.title  = qsTr("Error") + translationManager.emptyString;
                    informationPopup.text = qsTr("Wrong password");
                    informationPopup.open()
                    informationPopup.onCloseCallback = function() {
                        transactionConfirmationPasswordDialog.open()
                    }
                }
                transactionConfirmationPasswordDialog.password = ""
            }
            transactionConfirmationPasswordDialog.open()
        }
    }

    StandardDialog {
        id: confirmationDialog
        property var onAcceptedCallback
        property var onRejectedCallback
        onAccepted:  {
            if (onAcceptedCallback)
                onAcceptedCallback()
        }
        onRejected: {
            if (onRejectedCallback)
                onRejectedCallback();
        }
    }


    //Open Wallet from file
    FileDialog {
        id: fileDialog
        title: "Please choose a file"
        folder: "file://" + edollarAccountsDir
        nameFilters: [ "Wallet files (*.keys)"]

        onAccepted: {
            console.log('open file dialog, path=', walletManager.urlToLocalPath(fileDialog.fileUrl))
            persistentSettings.wallet_path = walletManager.urlToLocalPath(fileDialog.fileUrl)
            initialize();
        }
        onRejected: {
            console.log("Canceled")
            rootItem.state = "wizard";
        }

    }

    PasswordDialog {
        id: passwordDialog

        onAccepted: {
            walletPassword = passwordDialog.password
            appWindow.initialize();
        }
        onRejected: {
            //appWindow.enableUI(false)
            walletPassword = ""
            rootItem.state = "wizard"
        }

    }

    PasswordDialog {
        id: transactionConfirmationPasswordDialog
        property var onAcceptedCallback
        onAccepted: {
            if (onAcceptedCallback())
                onAcceptedCallback();
        }
    }


    DaemonManagerDialog {
        id: daemonManagerDialog
        onRejected: {
            //loadPage("Settings");
        }

    }

    ProcessingSplash {
        id: splash
        width: appWindow.width / 1.5
        height: appWindow.height / 2
        x: (appWindow.width - width) / 2 + appWindow.x
        y: (appWindow.height - height) / 2 + appWindow.y
        messageText: qsTr("Please wait...")
    }

    Item {
        id: rootItem
        anchors.fill: parent
        clip: true

        state: "wizard"
        states: [
            State {
                name: "wizard"
                //PropertyChanges { target: mainPage; visible: false }
                //PropertyChanges { target: persistentSettings; visible:false }
                PropertyChanges {target: navPane; visible: false}
                PropertyChanges {target: headerTitleBar; visible: false}
                PropertyChanges {target: titleBarFloating; visible: false}
            }, State {
                name: "normal"
                //PropertyChanges { target: mainPage; visible: true }
                PropertyChanges { target: wizard; visible: false }
                PropertyChanges {target: navPane; visible: true}
                PropertyChanges {target: headerTitleBar; visible: true}
                PropertyChanges {target: titleBarFloating; visible: true}

            }
        ]


        TipItem {
            id: tipItem
            text: qsTr("send to the same destination") + translationManager.emptyString
            visible: false
        }

        WizardMain {
            id: wizard
            anchors.fill: parent
            onUseEdollarClicked: {
                console.log('onUseEdollarClicked ... Iswallet? ', currentWallet? ' OK': ' NULL')
                rootItem.state = "normal" // TODO: listen for this state change in appWindow;
                //persistentSettings.visible = false
                appWindow.initialize();
                //show sync wallet
                showProcessingSplash("Refreshing your wallet, please wait ...")

            }
            onOpenWalletFromFileClicked: {
                rootItem.state = "normal" // TODO: listen for this state change in appWindow;
                //persistentSettings.visible = false
                appWindow.openWalletFromFile();
            }
        }

        // new ToolTip
        Rectangle {
            id: toolTip
            property alias text: content.text
            width: content.width + 12
            height: content.height + 17
            color: "#FF6C3C"
            //radius: 3
            visible:false;

            Image {
                id: tip
                anchors.top: parent.bottom
                anchors.right: parent.right
                anchors.rightMargin: 5
                source: "../images/tip.png"
            }

            Text {
                id: content
                anchors.horizontalCenter: parent.horizontalCenter
                y: 6
                lineHeight: 0.7
                font.family: "Arial"
                font.pixelSize: 12
                color: "#FFFFFF"
            }
        }

        Notifier {
            visible:false
            id: notifier
        }
    }

    onClosing: {
        close.accepted = false;
        console.log("blocking close event");
        console.log('onClose ', persistentSettings.useRemoteNode)

        // If daemon is running - prompt user before exiting
        if(typeof daemonManager != "undefined" && daemonManager.running(persistentSettings.testnet)) {
            close.accepted = false;

            // Show confirmation dialog
            confirmationDialog.title = qsTr("Daemon is running");
            confirmationDialog.text  = qsTr("Daemon will still be running in background when GUI is closed.");
            confirmationDialog.icon = StandardIcon.Question
            confirmationDialog.cancelText = qsTr("Stop daemon")
            confirmationDialog.onAcceptedCallback = function() {
                closeAccepted();
            }

            confirmationDialog.onRejectedCallback = function() {
                daemonManager.stop(persistentSettings.testnet);
                closeAccepted();
            };

            confirmationDialog.open()

        } else {
            closeAccepted();
        }
    }

    function closeAccepted(){
        // Close wallet non async on exit
        daemonManager.exit();
        walletManager.closeWallet();
        Qt.quit();
    }

    function onWalletCheckUpdatesComplete(update) {
        if (update === "")
            return
        print("Update found: " + update)
        var parts = update.split("|")
        if (parts.length === 4) {
          var version = parts[0]
          var hash = parts[1]
          var user_url = parts[2]
          var auto_url = parts[3]
          var msg = qsTr("New version of edollar-wallet-gui is available: %1<br>%2").arg(version).arg(user_url) + translationManager.emptyString
          notifier.show(msg)
        }
        else {
          print("Failed to parse update spec")
        }
    }

    function checkUpdates() {
        //walletManager.checkUpdatesAsync("edollar-gui", "gui")
    }

    Timer {
        id: updatesTimer
        interval: 3600*1000; running: true; repeat: true
        onTriggered: checkUpdates()
    }

    function isDaemonLocal() {
        var daemonAddress = appWindow.persistentSettings.daemon_address
        if (daemonAddress === "")
            return false
        var daemonHost = daemonAddress.split(":")[0]
        if (daemonHost === "127.0.0.1" || daemonHost === "localhost")
            return true
        return false
    }

    function setLogLevel(logLevel) {
        console.log('Set loglevel ', logLevel)
        walletManager.setLogLevel(logLevel)
        persistentSettings.logLevel = logLevel
    }


} // app window
