import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0
import "../common"
import QtQuick.Dialogs 1.2
import edollarComponents.PendingTransaction 1.0
import "../components"
import edollarComponents.Wallet 1.0

import QtQuick.Window 2.2
import QtQuick.Controls.Styles 1.4

Flickable {
    id: transferPage
    visible: true
    enabled: true
    property string name: "Page Transfer"
    property string title: qsTr("Transfer")

    property int mWidth: appWindow.mWidth
    property int mHeight: appWindow.mHeight
    property int marginLeft: appWindow.mWidth/8
    property int marginTop: 20

    property bool sendMany: false

    width: mWidth

    signal paymentClicked(string address, string amount, int mixinCount,
                          int priority, string description)
    signal sweepUnmixableClicked()

    property string startLinkText: qsTr("<style type='text/css'>a {text-decoration: none; color: #FF6C3C; font-size: 14px;}</style><font size='2'> (</font><a href='#'>Start daemon</a><font size='2'>)</font>") + translationManager.emptyString
    property bool showAdvanced: false

    function scaleValueToMixinCount(scaleValue) {
        var scaleToMixinCount = [4,5,6,7,8,9,10,11,12,14,16,18,21,25];
        if (scaleValue < scaleToMixinCount.length) {
            return scaleToMixinCount[scaleValue];
        } else {
            return 0;
        }
    }

    function isValidOpenAliasAddress(address) {
      address = address.trim()
      var dot = address.indexOf('.')
      if (dot < 0)
        return false
      // we can get an awful lot of valid domains, including non ASCII chars... accept anything
      return true
    }

    function oa_message(text) {
      oaPopup.title = qsTr("OpenAlias error") + translationManager.emptyString
      oaPopup.text = text
      oaPopup.icon = StandardIcon.Information
      oaPopup.onCloseCallback = null
      oaPopup.open()
    }

    function updateMixin() {
        var fillLevel = privacyLevelItem.fillLevel
        var mixin = scaleValueToMixinCount(fillLevel)
        print ("PrivacyLevel changed:"  + fillLevel)
        print ("mixin count: "  + mixin)
        privacyLabel.text = qsTr("Privacy level (ringsize %1)").arg(mixin+1) + translationManager.emptyString
    }

    function updateFromQrCode(address, payment_id, amount, tx_description, recipient_name) {
        console.log("updateFromQrCode")
        addressLine.text = address
        paymentIdLine.text = payment_id
        amountLine.text = amount
        descriptionLine.text = recipient_name + " " + tx_description
        cameraUi.qrcode_decoded.disconnect(updateFromQrCode)
    }

    function clearFields() {
        addressLine.text = ""
        amountLine.text = ""
        descriptionLine.text = ""
    }

    function onSignalChange(on) {
        console.log('On signal change, sendMany: ', on)
        if (on) {
            sendMany = true
            marginTop = 10
            multiRecipientTable.height = 130
            multiRecipientTable.anchors.topMargin = 15
            amountLine.text = ""
            addressLine.text = ""
        } else {
            sendMany = false
            marginTop = 20
            multiRecipientTable.height = 2
            multiRecipientTable.anchors.topMargin = 0
            multipleRecipientModel.clear()
            amountLine.text = ""
            addressLine.text = ""
        }
    }

    // Information dialog
    StandardDialog {
        // dynamically change onclose handler
        property var onCloseCallback
        id: oaPopup
        cancelVisible: false
        onAccepted:  {
            if (onCloseCallback) {
                onCloseCallback()
            }
        }
    }

    //TODO: remove absolute position, add layout and responsive
    Rectangle {
        id: pageRoot
        width: mWidth
        height: mHeight
        x: 0
        y: 0

        Label {
          id: amountLabel
          anchors.top: parent.top
          anchors.topMargin: 20
          x: marginLeft
          text: "Amount"
          fontSize: 14
        }
        Label {
          id: transactionPriority
          anchors.top: parent.top
          anchors.topMargin: 20
          fontSize: 14
          x: 3*marginLeft
          text: "Transaction priority"
        }
        Label {
          id: sendManyLabel
          anchors.top: parent.top
          anchors.topMargin: 20
          fontSize: 14
          x: 5.5*marginLeft
          text: "Send to many"
        }
        LineEdit {
          id: amountLine
          anchors.top: amountLabel.bottom
          anchors.topMargin: 5
          x: marginLeft
          placeholderText: ""
          width: marginLeft
          readOnly: false
          enabled: appWindow.currentWallet && !appWindow.currentWallet.viewOnly
          visible: true
          validator: DoubleValidator {
              bottom: 0.0
              top: 1000000000.000000000 // who has 1 Billion EDL :D
              decimals: 9
              notation: DoubleValidator.StandardNotation
              locale: "C"
          }
      }

      StandardButton {
          id: amountAllButton
          anchors.top: amountLabel.bottom
          anchors.topMargin: 5
          x: marginLeft + amountLine.width + 5
          width: 80
          text: !sendMany? qsTr("All"): qsTr("Add")
          enabled : appWindow.currentWallet && !appWindow.currentWallet.viewOnly
          onClicked: {
              if (!sendMany) {
                  amountLine.text = "(all)"
                  return
              }
              var address = addressLine.text.trim()

              var address_ok = walletManager.addressValid(address, appWindow.testnet)
              var amount_ok = amountLine.text.length > 0

              if (!address_ok || !amount_ok) {
                  //appWindow.hideProcessingSplash()
                  transferInfo.title = qsTr("Error") + translationManager.emptyString;
                  if (!address_ok)
                    transferInfo.text  = qsTr("Invalid address")
                  else
                     transferInfo.text  = qsTr("Invalid amount")
                  transferInfo.icon  = StandardIcon.Critical
                  transferInfo.onCloseCallback = null
                  transferInfo.open()
                  return
              }

              multipleRecipientModel.append({'amount': amountLine.text, 'address': addressLine.text})
              amountLine.text = ""
              addressLine.text = ""
          }
      }

      ListModel {
           id: priorityModel

           ListElement { column1: qsTr("Slow (x0.25 fee)") ; column2: ""; priority: 1}
           ListElement { column1: qsTr("Default (x1 fee)") ; column2: ""; priority: 2 }
           ListElement { column1: qsTr("Fast (x5 fee)") ; column2: ""; priority: 3 }
           ListElement { column1: qsTr("Fastest (x41.5 fee)")  ; column2: "";  priority: 4 }

       }

      StandardDropdown {
        id: priorityDropdown
        anchors.top: transactionPriority.bottom
        anchors.topMargin: 5
        anchors.left: transactionPriority.left
        width: 2*marginLeft
        z: 1
        dataModel: priorityModel
        currentIndex: 1
        enabled: appWindow.currentWallet && !appWindow.currentWallet.viewOnly
      }

      SwitchButton {
          id: toggleSendMany
          anchors.top: sendManyLabel.bottom
          anchors.topMargin: 10
          anchors.left: sendManyLabel.left
          width: 80
          height: 30
          onToggleChange: onSignalChange(on)
      }

      Image {
          id: addressBook
          source: "qrc:///images/addressBook.png"
          width: 30
          height: 30
          anchors.top: toggleSendMany.top
          anchors.right: parent.right
          anchors.rightMargin: marginLeft
          //anchors.topMargin: 0
          MouseArea {
              id: addressBookArea
              anchors.fill: parent
              hoverEnabled: true
              onClicked: {
                  console.log("Show address book")
                  addressBookWindow.show()
              }
          }
      }

      Label {
        id: addressLabel
        x: marginLeft
        anchors.top: amountLine.bottom
        anchors.topMargin: marginTop
        fontSize: 14
        textFormat: Text.RichText
        text: qsTr("Address")
      }
      Label {
          id: selectAddressBook
          anchors.top: amountLine.bottom
          anchors.topMargin: marginTop
          anchors.right: parent.right
          anchors.rightMargin: marginLeft
          textFormat: Text.RichText
          text:  qsTr("Select from  <a href='#'>Address book</a>")
          onLinkActivated: addressBookWindow.open()
      }

      LineEdit {
        id: addressLine
        anchors.top: addressLabel.bottom
        anchors.topMargin: topMargin
        x: marginLeft
        fontSize: 12
        width: 6*marginLeft
        placeholderText: "ed..."
        readOnly: false
        enabled: appWindow.currentWallet && !appWindow.currentWallet.viewOnly
        // validator: RegExpValidator { regExp: /[0-9A-Fa-f]{95}/g }
      }


      //Send to multiple address, available only when toggle enabled
      Scroll {
          id: flickableScroll
          anchors.right: multiRecipientTable.right
          anchors.rightMargin: -14
          anchors.top: multiRecipientTable.top
          anchors.bottom: multiRecipientTable.bottom
          flickable: multiRecipientTable
          visible: sendMany
      }

      TransferManyTable {
          id: multiRecipientTable
          x: marginLeft
          width: 6*marginLeft
          anchors.top: addressLine.bottom
          anchors.topMargin: 0
          height: 2
          onContentYChanged: flickableScroll.flickableContentYChanged()
          model: multipleRecipientModel
          visible: sendMany
      }


      Label {
        id: descriptionLabel
        x: marginLeft
        anchors.top: multiRecipientTable.bottom
        anchors.topMargin: marginTop
        fontSize: 14
        text: qsTr("Description <font size='2'>( Optional )</font>")
      }

    LineEdit {
        id: descriptionLine
        x: marginLeft
        readOnly: false
        anchors.top: descriptionLabel.bottom
        anchors.topMargin: 5
        width: 6*marginLeft
        placeholderText: qsTr("Saved to local wallet history")
        enabled: appWindow.currentWallet && !appWindow.currentWallet.viewOnly
    }

    Label {
      id: privacyLevelLabel
      x: marginLeft
      anchors.top: descriptionLine.bottom
      anchors.topMargin: marginTop
      fontSize: 14
      textFormat: Text.RichText
      text: qsTr("<style type='text/css'>a {text-decoration: none; color: #FF6C3C; font-size: 14px;}</style>\
                  Privacy Level <font size='2'>  (Default: 4. more privacy, more fee)</font>")
      onLinkActivated: appWindow.showPageRequest("AddressBook")
    }
    PrivacyLevel {
        visible: true
        id: privacyLevelItem
        anchors.top: privacyLevelLabel.bottom
        anchors.topMargin: 5
        x: marginLeft
        width: 6*marginLeft
        onFillLevelChanged: updateMixin()
        enabled: appWindow.currentWallet && !appWindow.currentWallet.viewOnly
    }

    function checkInformation(amount, address, testnet) {
        if (sendMany) return multipleRecipientModel.count > 0
        address = address.trim()

        var amount_ok = amount.length > 0
        var address_ok = walletManager.addressValid(address, testnet)

        return amount_ok && address_ok
    }

    StandardButton {
        id: sendButton
        text: qsTr("Send")
        anchors.top: privacyLevelItem.bottom
        anchors.topMargin: marginTop/2
        width: 180
        x: mWidth/2 - 90
        visible: true
        enabled : pageRoot.checkInformation(amountLine.text, addressLine.text, appWindow.persistentSettings.testnet) && appWindow.currentWallet && !appWindow.currentWallet.viewOnly
        onClicked: {
            console.log("Transfer: paymentClicked")
            var priority = priorityModel.get(priorityDropdown.currentIndex).priority

            if (sendMany) {
                var dest = {};
                var totalSpend = 0
                for (var i = 0; i < multipleRecipientModel.count; ++i) {
                    var data = multipleRecipientModel.get(i)
                    console.log(data.address, ' ', data.amount)
                    var realAmount = walletManager.amountFromString(data.amount)
                    dest[data.address] = realAmount
                    totalSpend += realAmount
                }
                if (totalSpend > appWindow.currentWallet.unlockedBalance) {
                    appWindow.hideProcessingSplash()
                    transferInfo.title = qsTr("Error") + translationManager.emptyString;
                    transferInfo.text  = qsTr("Insufficient funds. Unlocked balance: %1")
                            .arg(walletManager.displayAmount(currentWallet.unlockedBalance))
                            + translationManager.emptyString

                    transferInfo.icon  = StandardIcon.Critical
                    transferInfo.onCloseCallback = null
                    transferInfo.open()
                    return
                }
                if (totalSpend <= 0) {
                    appWindow.hideProcessingSplash()
                    transferInfo.title = qsTr("Error") + translationManager.emptyString;
                    transferInfo.text  = qsTr("Amount is wrong: expected number from %1 to %2")
                            .arg(walletManager.displayAmount(0))
                            .arg(walletManager.maximumAllowedAmountAsSting())
                            + translationManager.emptyString

                    transferInfo.icon  = StandardIcon.Critical
                    transferInfo.onCloseCallback = null
                    transferInfo.open()
                    return
                }
                appWindow.handlePaymentMany(dest, scaleValueToMixinCount(privacyLevelItem.fillLevel),
                                    priority, descriptionLine.text)
            }
            else {
                console.log("priority: " + priority)
                console.log("amount: " + amountLine.text)
                addressLine.text = addressLine.text.trim()
                appWindow.handlePayment(addressLine.text, amountLine.text, scaleValueToMixinCount(privacyLevelItem.fillLevel),
                                        priority, descriptionLine.text)
            }
        }
     }


   }

    ListModel {
        id: multipleRecipientModel
    }

    AddressBookWindow {
        id: addressBookWindow
        onAccepted: {

        }
    }

    StandardDialog {
        // dynamically change onclose handler
        property var onCloseCallback
        id: transferInfo
        cancelVisible: false
        onAccepted:  {
            if (onCloseCallback) {
                onCloseCallback()
            }
        }
    }

    function deleteReceipent(index) {
        multipleRecipientModel.remove(index)
    }

    function onAddressSelected(address) {
        console.log('[Transfer] address selected ', address)
        addressLine.text = address
    }

    function onTransferCompleted() {
        console.log("Transfer completed!")
        amountLine.text = ""
        addressLine.text = ""
        descriptionLine.text = ""
        multipleRecipientModel.clear()
    }

    function onWalletConnected() {
        console.log('[Transfer] onWalletConnected')
        if (!appWindow.currentWallet) return
        addressBookWindow.model = appWindow.currentWallet.addressBookModel
//        if (!appWindow.currentWallet.viewOnly) {
//            priorityDropdown.enabled = true
//            amountAllButton.enabled = true
//            addressLine.enabled = true
//        }
    }

    function onWalletClosed() {
        console.log('[Transfer] on wallet close')
        onTransferCompleted()
        //reset all field
    }

    Component.onCompleted: {
        appWindow.transferCompleted.connect(onTransferCompleted)
        appWindow.walletConnected.connect(onWalletConnected)
        appWindow.walletClosed.connect(onWalletClosed)
    }


} // flickable
