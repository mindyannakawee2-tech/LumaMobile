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
#include "AppRegistry.h"


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

    AppRegistry appRegistry;


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


    engine.rootContext()
        ->setContextProperty(
            "LumaApps",
            &appRegistry
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


    qInfo()
        << "Luma applications:"
        << appRegistry.apps().size();


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
