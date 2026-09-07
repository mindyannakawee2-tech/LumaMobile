#include <QGuiApplication>

#include <QQmlApplicationEngine>
#include <QQmlContext>

#include <QWindow>
#include <QUrl>
#include <QString>
#include <QDebug>

#include <QtWebEngineQuick/qtwebenginequickglobal.h>

#include "SystemBackend.h"
#include "InputBackend.h"


int main(
    int argc,
    char *argv[]
)
{
    QtWebEngineQuick::initialize();


    QGuiApplication app(
        argc,
        argv
    );


    app.setApplicationName(
        "LumaShell"
    );


    app.setOrganizationName(
        "Luma"
    );


    SystemBackend systemBackend;

    InputBackend inputBackend;


    QQmlApplicationEngine engine;


    engine.rootContext()
        ->setContextProperty(
            "LumaSystem",
            &systemBackend
        );


    engine.rootContext()
        ->setContextProperty(
            "LumaInput",
            &inputBackend
        );


    const QString qmlDir =
        QStringLiteral(
            LUMASHELL_QML_DIR
        );


    engine.addImportPath(
        qmlDir
    );


    const QString mainFile =
        qmlDir
        + QStringLiteral(
            "/Main.qml"
        );


    qInfo()
        << "LumaShell QML:"
        << mainFile;


    engine.load(
        QUrl::fromLocalFile(
            mainFile
        )
    );


    if (
        engine.rootObjects()
            .isEmpty()
    ) {

        qCritical()
            << "LumaShell failed to load Main.qml";

        return 1;
    }


    /*
     * Host development remains windowed.
     *
     * Real LumaMobile boots full-screen.
     */

    if (
        qEnvironmentVariableIsSet(
            "LUMA_OS_BOOT"
        )
    ) {

        QObject *rootObject =
            engine.rootObjects()
                .first();


        QWindow *window =
            qobject_cast<QWindow *>(
                rootObject
            );


        if (window)
            window->showFullScreen();
    }


    return app.exec();
}
