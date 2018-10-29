#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
#include <QTranslator>
#include <QQmlContext>

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QStandardPaths>
#include <QDebug>
#include <QObject>
#include <QMap>
#include "clipboardAdapter.h"
#include "filter.h"
#include "oscursor.h"
#include "oshelper.h"
#include "WalletManager.h"
#include "Wallet.h"
#include "QRCodeImageProvider.h"
#include "PendingTransaction.h"
#include "UnsignedTransaction.h"
#include "TranslationManager.h"
#include "TransactionInfo.h"
#include "TransactionHistory.h"
#include "model/TransactionHistoryModel.h"
#include "model/TransactionHistorySortFilterModel.h"
#include "AddressBook.h"
#include "model/AddressBookModel.h"
#include "Subaddress.h"
#include "model/SubaddressModel.h"
#include "wallet/wallet2_api.h"

// IOS exclusions
#ifndef Q_OS_IOS
#include "daemon/DaemonManager.h"
#endif

#ifdef WITH_SCANNER
#include "QrCodeScanner.h"
#endif

#include "MainApp.h"

int main(int argc, char *argv[])
{
    Edollar::Wallet::init(argv[0], "edollar-wallet-gui");
//    qInstallMessageHandler(messageHandler);
    //QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    qputenv("QT_QUICK_CONTROLS_STYLE", "material");
    //QGuiApplication app(argc, argv);

//    QTranslator translator;
//    if (translator.load(QLocale(), QLatin1String("edollar-wallet-gui"), QLatin1String("_"), QLatin1String(":/translations"))) {
//        app.installTranslator(&translator);
//    } else {
//        qDebug() << "cannot load translator " << QLocale::system().name() << " check content of translations.qrc";
//    }

    MainApp app(argc, argv);

    qDebug() << "app startd";

    app.setApplicationName("edollar-core");
    app.setOrganizationDomain("edollar.cash");
    app.setOrganizationName("edollar-project");

    filter *eventFilter = new filter;
    app.installEventFilter(eventFilter);


    qDebug() << "app startd";

    // registering types for QML
    qmlRegisterType<clipboardAdapter>("edollarComponents.Clipboard", 1, 0, "Clipboard");

    qmlRegisterUncreatableType<Wallet>("edollarComponents.Wallet", 1, 0, "Wallet", "Wallet can't be instantiated directly");


    qmlRegisterUncreatableType<PendingTransaction>("edollarComponents.PendingTransaction", 1, 0, "PendingTransaction",
                                                   "PendingTransaction can't be instantiated directly");

    qmlRegisterUncreatableType<UnsignedTransaction>("edollarComponents.UnsignedTransaction", 1, 0, "UnsignedTransaction",
                                                   "UnsignedTransaction can't be instantiated directly");

    qmlRegisterUncreatableType<WalletManager>("edollarComponents.WalletManager", 1, 0, "WalletManager",
                                                   "WalletManager can't be instantiated directly");

    qmlRegisterUncreatableType<TranslationManager>("edollarComponents.TranslationManager", 1, 0, "TranslationManager",
                                                   "TranslationManager can't be instantiated directly");



    qmlRegisterUncreatableType<TransactionHistoryModel>("edollarComponents.TransactionHistoryModel", 1, 0, "TransactionHistoryModel",
                                                        "TransactionHistoryModel can't be instantiated directly");

    qmlRegisterUncreatableType<TransactionHistorySortFilterModel>("edollarComponents.TransactionHistorySortFilterModel", 1, 0, "TransactionHistorySortFilterModel",
                                                        "TransactionHistorySortFilterModel can't be instantiated directly");

    qmlRegisterUncreatableType<TransactionHistory>("edollarComponents.TransactionHistory", 1, 0, "TransactionHistory",
                                                        "TransactionHistory can't be instantiated directly");

    qmlRegisterUncreatableType<TransactionInfo>("edollarComponents.TransactionInfo", 1, 0, "TransactionInfo",
                                                        "TransactionHistory can't be instantiated directly");
#ifndef Q_OS_IOS
    qmlRegisterUncreatableType<DaemonManager>("edollarComponents.DaemonManager", 1, 0, "DaemonManager",
                                                   "DaemonManager can't be instantiated directly");
#endif
    qmlRegisterUncreatableType<AddressBookModel>("edollarComponents.AddressBookModel", 1, 0, "AddressBookModel",
                                                        "AddressBookModel can't be instantiated directly");

    qmlRegisterUncreatableType<AddressBook>("edollarComponents.AddressBook", 1, 0, "AddressBook",
                                                        "AddressBook can't be instantiated directly");

     qmlRegisterUncreatableType<SubaddressModel>("edollarComponents.SubaddressModel", 1, 0, "SubaddressModel",
                                                        "SubaddressModel can't be instantiated directly");

    qmlRegisterUncreatableType<Subaddress>("edollarComponents.Subaddress", 1, 0, "Subaddress",
                                                        "Subaddress can't be instantiated directly");
                                                        
    qRegisterMetaType<PendingTransaction::Priority>();
    qRegisterMetaType<TransactionInfo::Direction>();
    qRegisterMetaType<TransactionHistoryModel::TransactionInfoRole>();

#ifdef WITH_SCANNER
    qmlRegisterType<QrCodeScanner>("edollarComponents.QRCodeScanner", 1, 0, "QRCodeScanner");
#endif

    QQmlApplicationEngine engine;

    OSCursor cursor;
    engine.rootContext()->setContextProperty("globalCursor", &cursor);
    OSHelper osHelper;
    engine.rootContext()->setContextProperty("oshelper", &osHelper);

    engine.rootContext()->setContextProperty("walletManager", WalletManager::instance());

    engine.rootContext()->setContextProperty("translationManager", TranslationManager::instance());

    engine.addImageProvider(QLatin1String("qrcode"), new QRCodeImageProvider());
    const QStringList arguments = QCoreApplication::arguments();

    engine.rootContext()->setContextProperty("mainApp", &app);

// Exclude daemon manager from IOS
#ifndef Q_OS_IOS
    DaemonManager * daemonManager = DaemonManager::instance(&arguments);
    engine.rootContext()->setContextProperty("daemonManager", daemonManager);
#endif

//  export to QML Edollar accounts root directory
//  wizard is talking about where
//  to save the wallet file (.keys, .bin), they have to be user-accessible for
//  backups - I reckon we save that in My Documents\Edollar Accounts\ on
//  Windows, ~/Edollar Accounts/ on nix / osx
    bool isWindows = false;
    bool isIOS = false;
    bool isMac = false;
#ifdef Q_OS_WIN
    isWindows = true;
    QStringList edollarAccountsRootDir = QStandardPaths::standardLocations(QStandardPaths::DocumentsLocation);
#elif defined(Q_OS_IOS)
    isIOS = true;
    QStringList edollarAccountsRootDir = QStandardPaths::standardLocations(QStandardPaths::DocumentsLocation);
#elif defined(Q_OS_UNIX)
    QStringList edollarAccountsRootDir = QStandardPaths::standardLocations(QStandardPaths::HomeLocation);
#endif
#ifdef Q_OS_MAC
    isMac = true;
#endif

    engine.rootContext()->setContextProperty("isWindows", isWindows);
    engine.rootContext()->setContextProperty("isIOS", isIOS);

    if (!edollarAccountsRootDir.empty()) {
        QString edollarAccountsDir = edollarAccountsRootDir.at(0) + "/Edollar/wallets";
        engine.rootContext()->setContextProperty("edollarAccountsDir", edollarAccountsDir);
    }


    // Get default account name
    QString accountName = qgetenv("USER"); // mac/linux
    if (accountName.isEmpty()){
        accountName = qgetenv("USERNAME"); // Windows
    }
    if (accountName.isEmpty()) {
        accountName = "My Edollar Account";
    }

    engine.rootContext()->setContextProperty("defaultAccountName", accountName);
    engine.rootContext()->setContextProperty("applicationDirectory", QApplication::applicationDirPath());

    bool builtWithScanner = false;
#ifdef WITH_SCANNER
    builtWithScanner = true;
#endif
    engine.rootContext()->setContextProperty("builtWithScanner", builtWithScanner);

    // Load main window (context properties needs to be defined obove this line)
    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));
    QObject *rootObject = engine.rootObjects().first();
    qDebug() << "Object name:" <<rootObject->objectName();

#ifdef WITH_SCANNER
    QObject *qmlCamera = rootObject->findChild<QObject*>("qrCameraQML");
    if( qmlCamera ){
        qDebug() << "QrCodeScanner : object found";
        QCamera *camera_ = qvariant_cast<QCamera*>(qmlCamera->property("mediaObject"));
        QObject *qmlFinder = rootObject->findChild<QObject*>("QrFinder");
        qobject_cast<QrCodeScanner*>(qmlFinder)->setSource(camera_);
    } else {
        qDebug() << "QrCodeScanner : something went wrong !";
    }
#endif

//    QObject::connect(eventFilter, SIGNAL(sequencePressed(QVariant,QVariant)), rootObject, SLOT(sequencePressed(QVariant,QVariant)));
//    QObject::connect(eventFilter, SIGNAL(sequenceReleased(QVariant,QVariant)), rootObject, SLOT(sequenceReleased(QVariant,QVariant)));
//    QObject::connect(eventFilter, SIGNAL(mousePressed(QVariant,QVariant,QVariant)), rootObject, SLOT(mousePressed(QVariant,QVariant,QVariant)));
//    QObject::connect(eventFilter, SIGNAL(mouseReleased(QVariant,QVariant,QVariant)), rootObject, SLOT(mouseReleased(QVariant,QVariant,QVariant)));

    return app.exec();
}
