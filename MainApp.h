#ifndef MAINAPP_H
#define MAINAPP_H
#include <QApplication>

class MainApp : public QApplication
{
    Q_OBJECT
public:
    MainApp(int &argc, char** argv) : QApplication(argc, argv) {
        // default theme is light
        mIsDarkTheme = false;
        // default primary color is Blue
        mPrimaryPalette = 4;
        // default accent color is orange
        mAccentPalette = 14;
    }

    Q_INVOKABLE
    QStringList swapThemePalette();

    Q_INVOKABLE
    QStringList defaultThemePalette();

    Q_INVOKABLE
    QStringList primaryPalette(const int paletteIndex);

    Q_INVOKABLE
    QStringList accentPalette(const int paletteIndex);

    Q_INVOKABLE
    QStringList defaultPrimaryPalette();

    Q_INVOKABLE
    QStringList defaultAccentPalette();

private:
    bool event(QEvent *e);
signals:
    void closing();

private:
    bool mIsDarkTheme;
    int mPrimaryPalette;
    int mAccentPalette;
};

#endif // MAINAPP_H


