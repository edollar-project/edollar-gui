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
import edollarComponents.TransactionHistory 1.0
import edollarComponents.TransactionInfo 1.0
import edollarComponents.TransactionHistoryModel 1.0

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
    id: appWindowGui
//    visible: true
//    objectName: "appWindowGui"
//    title: "edollar wallet"
//    //flags: Qt.Window | Qt.WindowCloseButtonHint | ~Qt.WindowMaximizeButtonHint//Qt.WindowMinimizeButtonHint | Qt.WindowCloseButtonHint | Qt.WindowTitleHint
//    //flags: persistentSettings.customDecorations ? (Qt.FramelessWindowHint | Qt.WindowSystemMenuHint | Qt.Window | Qt.WindowMinimizeButtonHint) : (Qt.WindowSystemMenuHint | Qt.Window | Qt.WindowMinimizeButtonHint | Qt.WindowCloseButtonHint | Qt.WindowTitleHint | Qt.WindowMaximizeButtonHint)

//    signal walletConnected()
//    signal transferCompleted()

//    //VIEW PROPERTIES
//    width: appWindow.mWidth     //Screen.desktopAvailableWidth
//    height: appWindow.height    //Screen.desktopAvailableHeight
//    maximumWidth: appWindow.mWidth
//    property bool isLandscape: width > height
//    // primary and accent properties:
//    property variant primaryPalette: mainApp.primaryPalette(4)
//    property color primaryLightColor: primaryPalette[0]
//    property color primaryColor: primaryPalette[1]
//    property color primaryDarkColor: primaryPalette[2]
//    property color textOnPrimaryLight: primaryPalette[3]
//    property color textOnPrimary: primaryPalette[4]
//    property color textOnPrimaryDark: primaryPalette[5]
//    property string iconOnPrimaryLightFolder: primaryPalette[6]
//    property string iconOnPrimaryFolder: primaryPalette[7]
//    property string iconOnPrimaryDarkFolder: primaryPalette[8]
//    property variant accentPalette: mainApp.defaultAccentPalette()
//    property color accentColor: accentPalette[0]
//    property color textOnAccent: accentPalette[1]
//    property string iconOnAccentFolder: accentPalette[2]
//    Material.primary: primaryColor
//    Material.accent: accentColor
//    // theme Dark vs Light properties:
//    property variant themePalette: mainApp.defaultThemePalette()
//    property color dividerColor: themePalette[0]
//    property color cardAndDialogBackground: themePalette[1]
//    property real primaryTextOpacity: themePalette[2]
//    property real secondaryTextOpacity: themePalette[3]
//    property real dividerOpacity: themePalette[4]
//    property real iconActiveOpacity: themePalette[5]
//    property real iconInactiveOpacity: themePalette[6]
//    property string iconFolder: themePalette[7]
//    property int isDarkTheme: themePalette[8]
//    property color flatButtonTextColor: themePalette[9]
//    property color popupTextColor: themePalette[10]
//    property real toolBarActiveOpacity: themePalette[11]
//    property real toolBarInactiveOpacity: themePalette[12]
//    // Material.dropShadowColor  OK for Light, but too dark for dark theme
//    property color dropShadow: isDarkTheme? "#E4E4E4" : Material.dropShadowColor
//    onIsDarkThemeChanged: {
//        if(isDarkTheme == 1) {
//            Material.theme = Material.Dark
//        } else {
//            Material.theme = Material.Light
//        }
//    }
//    // font sizes - defaults from Google Material Design Guide
//    property int fontSizeDisplay4: 112
//    property int fontSizeDisplay3: 56
//    property int fontSizeDisplay2: 45
//    property int fontSizeDisplay1: 34
//    property int fontSizeHeadline: 24
//    property int fontSizeTitle: 20
//    property int fontSizeSubheading: 16
//    property int fontSizeBodyAndButton: 14 // is Default
//    property int fontSizeCaption: 12
//    // fonts are grouped into primary and secondary with different Opacity
//    // to make it easier to get the right property,
//    // here's the opacity per size:
//    property real opacityDisplay4: secondaryTextOpacity
//    property real opacityDisplay3: secondaryTextOpacity
//    property real opacityDisplay2: secondaryTextOpacity
//    property real opacityDisplay1: secondaryTextOpacity
//    property real opacityHeadline: primaryTextOpacity
//    property real opacityTitle: primaryTextOpacity
//    property real opacitySubheading: primaryTextOpacity
//    // body can be both: primary or secondary text
//    property real opacityBodyAndButton: primaryTextOpacity
//    property real opacityBodySecondary: secondaryTextOpacity
//    property real opacityCaption: secondaryTextOpacity
//    //

//    // TabBar properties
//    property string titleAndTabBarSource: "tabs/TitleWithIconTextTabBar.qml"
//    property bool tabBarIsFixed: true
//    property bool tabBarInsideTitleBar: true

//    property var tabButtonModel: [          {"name": "Dashboard", "icon": "edollar-home.png"},
//                                            {"name": "Send", "icon": "edollar-send.png"},
//                                            {"name": "Receive", "icon": "edollar-receive.png"},
//                                            {"name": "History", "icon": "edollar-history.png"},
//                                            {"name": "Setting", "icon": "edollar-setting.png"}]

//    //APP PROPERTY
//    property string walletAddress: ""

//    header: isLandscape? null : headerTitleBar

//    // loader alias
//    property alias loaderItem: dashboardLoader.item

//    Loader {
//        id: headerTitleBar
//        visible: !isLandscape
//        active: !isLandscape
//        source: titleAndTabBarSource
//        onLoaded: {
//            if(item) {
//                item.currentIndex = navPane.currentIndex
//                item.text = qsTr("Edollar Wallet")
//            }
//        }
//    }
//    // in LANDSCAPE header is null and we have a floating TitleBar
//    // hint: TitleBar shadow not visible in Landscape
//    // reason: TabBar must be defined inside ToolBar
//    // but they're defined in column layout - haven't redesigned for this example
//    // only wanted to demonstrate HowTo use fix and floating Titles
//    Loader {
//        id: titleBarFloating
//        visible: isLandscape
//        anchors.top: parent.top
//        anchors.left: parent.left
//        anchors.right: parent.right
//        active: isLandscape
//        source: titleAndTabBarSource
//        onLoaded: {
//            if(item) {
//                item.currentIndex = navPane.currentIndex
//                item.text = qsTr("Edollar Wallet")
//            }
//        }
//    }

//    SwipeView {
//        id: navPane
//        focus: true
//        // anchors.fill: parent
//        anchors.top: isLandscape? titleBarFloating.bottom : parent.top
//        anchors.topMargin: isLandscape? 6 : 0
//        anchors.left: parent.left
//        anchors.right: parent.right
//        anchors.bottom: parent.bottom
//        currentIndex: 0
//        // currentIndex is the NEXT index swiped to
//        onCurrentIndexChanged: {
//            if(isLandscape) {
//                titleBarFloating.item.currentIndex = currentIndex
//            } else {
//                headerTitleBar.item.currentIndex = currentIndex
//            }
//            switch(currentIndex) {
//            case 1:
//                pageReceiveLoader.active = true
//                break;
//            case 2:
//                pageReceiveLoader.active = true
//                pageHistoryLoader.active = true
//                break;
//            case 3:
//                pageReceiveLoader.active = true
//                pageHistoryLoader.active = true
//                pageSettingLoader.active = true
//                break;
//            case 4:
//                pageHistoryLoader.active = true
//                pageSettingLoader.active = true
//                break;
//            }
//        }

//        // support of BACK key
//        property bool firstPageInfoRead: false
//        Keys.onBackPressed: {
//            event.accepted = navPane.currentIndex > 0 || !firstPageInfoRead
//            if(navPane.currentIndex > 0) {
//                onePageBack()
//                return
//            }
//            // first time we reached first tab
//            // user gets Popupo Info
//            // hitting again BACK will close the app
//            if(!firstPageInfoRead) {
//                firstPageReached()
//            }
//            // We don't have to manually cleanup loaded Pages
//            // While shutting down the app, all loaded Pages will be deconstructed
//            // and cleanup called
//        }

//        function onePageBack() {
//            if(navPane.currentIndex == 0) {
//                firstPageReached()
//                return
//            }
//            navPane.goToPage(currentIndex - 1)
//        } // onePageBack

//        function onePageForward() {
//            if(navPane.currentIndex == 4) {
//                lastPageReached()
//                return
//            }
//            navPane.goToPage(currentIndex + 1)
//        }

//        function goToPage(pageIndex) {
//            if(pageIndex == navPane.currentIndex) {
//                // it's the current page
//                return
//            }
//            if(pageIndex > 4 || pageIndex < 0) {
//                return
//            }
//            navPane.currentIndex = pageIndex
//        } // goToPage
//        // Page 1 and 2 preloaded to be able to swipe
//        // other pages will be lazy loaded first time they're needed
//        Loader {
//            // index 0
//            id: dashboardLoader
//            active: true
//            source: "pages/Dashboard.qml"
//            onLoaded: console.log("Loaded dashboard ...")
//        }
//        Loader {
//            // index 1
//            id: pageTransferLoader
//            active: true
//            source: "pages/Transfer.qml"
//        }
//        Loader {
//            // Receiver page
//            id: pageReceiveLoader
//            active: false
//            //source: "pages/Receive.qml"
//        }
//        Loader {
//            // index 3
//            id: pageHistoryLoader
//            active: false
//            source: "pages/History.qml"
//        }
//        Loader {
//            // index 4
//            id: pageSettingLoader
//            active: false
//            source: "pages/Settings.qml"
//        }

//    } // navPane

//    function switchPrimaryPalette(paletteIndex) {
//        primaryPalette = mainApp.primaryPalette(paletteIndex)
//    }
//    function switchAccentPalette(paletteIndex) {
//        accentPalette = mainApp.accentPalette(paletteIndex)
//    }

//    // we can loose the focus if Menu or Popup is opened
//    function resetFocus() {
//        navPane.focus = true
//    }

//    //
//    PopupPalette {
//        id: popup
//        onAboutToHide: {
//            resetFocus()
//        }
//    }

//    function walletConnect() {
//        walletConnected()
//    }

//    function onPageCompleted() {
//        console.log("Main page on completed ==============")
//        pageReceiveLoader.source = "pages/Receive.qml"
//        console.log("status: " + pageReceiveLoader.status)
//        if (!pageReceiveLoader.item)
//            console.log("pageReceiveLoader item is null")
//        else {
//            pageReceiveLoader.item.test()
//            pageReceiveLoader.item.onPageCompleted()
//            walletConnected()
//        }

//        if (loaderItem) {
//            loaderItem.onPageCompleted()
//        }
//    }

//    //update wallet balance
//    function updateWalletBalance(balance, unlockedBalance) {
//       if (loaderItem) {
//           console.log("update wallet ...")
//           console.log("balance = " + balance)
//           loaderItem.balanceText = balance + ' EDL'
//           loaderItem.unlockedBalanceText = unlockedBalance + ' EDL'
//       } else {
//          console.log("Dashboard loader is null")
//       }
//    }

//    function updateConnected(isConnected) {
//        console.log("Connect to daemon: " + isConnected)
//        if (loaderItem) {
//            loaderItem.networkStatus.connected = isConnected
//        }
//    }

//    function updateSync(isSync, currentBlock, targetBlock) {
////        if (loaderItem) {
////            loaderItem.progressBar.updateProgress(currentBlock, targetBlock)
////            loaderItem.progressBar.visible = true //isSync
////        }
//    }


//    function updateRecentTransaction(historyModel) {

//    }

//    function firstPageReached() {
//        popupInfo.text = qsTr("No more Tabs\nLeftmost Tab reached")
//        popupInfo.buttonText = qsTr("OK")
//        popupInfo.open()
//        navPane.firstPageInfoRead = true
//    }
//    function lastPageReached() {
//        popupInfo.text = qsTr("No more Tabs\nRightmost Tab reached")
//        popupInfo.buttonText = qsTr("OK")
//        popupInfo.open()
//    }
//    function pageNotValid(pageNumber) {
//        popupInfo.text = qsTr("Page %1 not valid.\nPlease tap 'Done' Button","").arg(pageNumber)
//        popupInfo.buttonText = qsTr("So Long, and Thx For All The Fish")
//        popupInfo.open()
//    }
//    function showInfo(info) {
//        popupInfo.text = info
//        popupInfo.buttonText = qsTr("OK")
//        popupInfo.open()
//    }

//    function transferDone() {
//        transferCompleted()
//    }
//    // Unfortunately no SIGNAL if end or beginning reached from SWIPE GESTURE
//    // so at the moment user gets no visual feedback
//    // TODO Bugreport
//    PopupInfo {
//        id: popupInfo
//        onAboutToHide: {
//            popupInfo.stopTimer()
//            resetFocus()
//        }
//    } // popupInfo

//    Component.onCompleted: {
//        x = (Screen.width - width) / 2
//        y = (Screen.height - maxWindowHeight) / 2
//    }

//    onClosing: {
//        console.log('on close main page')
//        appWindow.close()
//    }
} // app window
