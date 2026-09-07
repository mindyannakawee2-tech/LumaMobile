#include "AppRegistry.h"

#include <QDir>
#include <QDirIterator>
#include <QFile>
#include <QFileInfo>
#include <QHash>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTimer>
#include <QUrl>

#include <algorithm>


AppRegistry::AppRegistry(
    QObject *parent
)
    : QObject(parent)
{
    connect(
        &m_watcher,
        &QFileSystemWatcher::directoryChanged,
        this,
        [this](const QString &) {

            QTimer::singleShot(
                100,
                this,
                &AppRegistry::reload
            );
        }
    );


    connect(
        &m_watcher,
        &QFileSystemWatcher::fileChanged,
        this,
        [this](const QString &) {

            QTimer::singleShot(
                100,
                this,
                &AppRegistry::reload
            );
        }
    );


    reload();
}


QVariantList AppRegistry::apps() const
{
    return m_apps;
}


QStringList AppRegistry::manifestDirectories() const
{
    QStringList result;


    auto addDirectory =
        [&result](const QString &path) {

            if (
                !path.isEmpty() &&
                !result.contains(path)
            ) {
                result.append(
                    QDir(path).absolutePath()
                );
            }
        };


#ifdef LUMASHELL_APP_DIR

    addDirectory(
        QStringLiteral(
            LUMASHELL_APP_DIR
        )
    );

#endif


    // System-installed applications.

    addDirectory(
        QStringLiteral(
            "/usr/share/luma/apps"
        )
    );


    // Persistent LumaMobile user applications.

    if (
        QDir(
            QStringLiteral(
                "/data/home/luma"
            )
        ).exists()
    ) {

        const QString dataApps =
            QStringLiteral(
                "/data/home/luma/.local/share/luma/apps"
            );

        QDir().mkpath(
            dataApps
        );

        addDirectory(
            dataApps
        );
    }


    // Host/development user applications.

    const QString userApps =
        QDir::home().filePath(
            QStringLiteral(
                ".local/share/luma/apps"
            )
        );

    QDir().mkpath(
        userApps
    );

    addDirectory(
        userApps
    );


    // Optional developer override.
    //
    // Example:
    //
    // LUMA_APP_DIR=/my/apps ./run-preview.sh

    const QString extra =
        qEnvironmentVariable(
            "LUMA_APP_DIR"
        );


    if (!extra.isEmpty()) {

        const QStringList paths =
            extra.split(
                QDir::listSeparator(),
                Qt::SkipEmptyParts
            );


        for (
            const QString &path :
            paths
        ) {
            addDirectory(
                path
            );
        }
    }


    return result;
}


QVariantMap AppRegistry::loadManifest(
    const QString &path
) const
{
    QFile file(
        path
    );


    if (
        !file.open(
            QIODevice::ReadOnly
        )
    ) {
        return {};
    }


    QJsonParseError error;


    const QJsonDocument document =
        QJsonDocument::fromJson(
            file.readAll(),
            &error
        );


    if (
        error.error !=
        QJsonParseError::NoError
        ||
        !document.isObject()
    ) {
        return {};
    }


    const QJsonObject object =
        document.object();


    if (
        !object
            .value(
                QStringLiteral(
                    "enabled"
                )
            )
            .toBool(true)
    ) {
        return {};
    }


    const QString id =
        object
            .value(
                QStringLiteral(
                    "id"
                )
            )
            .toString()
            .trimmed();


    QString title =
        object
            .value(
                QStringLiteral(
                    "title"
                )
            )
            .toString()
            .trimmed();


    if (title.isEmpty()) {

        title =
            object
                .value(
                    QStringLiteral(
                        "name"
                    )
                )
                .toString()
                .trimmed();
    }


    const QString entry =
        object
            .value(
                QStringLiteral(
                    "entry"
                )
            )
            .toString()
            .trimmed();


    if (
        id.isEmpty() ||
        title.isEmpty() ||
        entry.isEmpty()
    ) {
        return {};
    }


    const QFileInfo manifestInfo(
        path
    );


    const QDir manifestDir(
        manifestInfo.absolutePath()
    );


    auto resolvedPath =
        [&manifestDir](
            const QString &value
        ) -> QString
        {
            if (value.isEmpty())
                return {};


            QFileInfo info(
                value
            );


            if (
                !info.isAbsolute()
            ) {
                info =
                    QFileInfo(
                        manifestDir.filePath(
                            value
                        )
                    );
            }


            return
                info.absoluteFilePath();
        };


    const QString entryPath =
        resolvedPath(
            entry
        );


    if (
        !QFileInfo::exists(
            entryPath
        )
    ) {
        return {};
    }


    const QString iconPath =
        resolvedPath(
            object
                .value(
                    QStringLiteral(
                        "icon"
                    )
                )
                .toString()
        );


    QVariantMap app;


    app[
        QStringLiteral(
            "id"
        )
    ] = id;


    app[
        QStringLiteral(
            "title"
        )
    ] = title;


    app[
        QStringLiteral(
            "glyph"
        )
    ] =
        object
            .value(
                QStringLiteral(
                    "glyph"
                )
            )
            .toString(
                title.left(1)
            );


    app[
        QStringLiteral(
            "accent"
        )
    ] =
        object
            .value(
                QStringLiteral(
                    "accent"
                )
            )
            .toString(
                QStringLiteral(
                    "#625FE7"
                )
            );


    app[
        QStringLiteral(
            "order"
        )
    ] =
        object
            .value(
                QStringLiteral(
                    "order"
                )
            )
            .toInt(
                1000
            );


    app[
        QStringLiteral(
            "dock"
        )
    ] =
        object
            .value(
                QStringLiteral(
                    "dock"
                )
            )
            .toBool(
                false
            );


    app[
        QStringLiteral(
            "home"
        )
    ] =
        object
            .value(
                QStringLiteral(
                    "home"
                )
            )
            .toBool(
                true
            );


    app[
        QStringLiteral(
            "entryUrl"
        )
    ] =
        QUrl::fromLocalFile(
            entryPath
        ).toString();


    app[
        QStringLiteral(
            "iconUrl"
        )
    ] =
        (
            !iconPath.isEmpty() &&
            QFileInfo::exists(
                iconPath
            )
        )
            ? QUrl::fromLocalFile(
                  iconPath
              ).toString()
            : QString();


    app[
        QStringLiteral(
            "manifest"
        )
    ] =
        manifestInfo
            .absoluteFilePath();


    return app;
}


void AppRegistry::reload()
{
    const QStringList directories =
        manifestDirectories();


    QHash<QString, QVariantMap>
        applications;


    QStringList filesToWatch;
    QStringList directoriesToWatch;


    for (
        const QString &directoryPath :
        directories
    ) {

        QDir directory(
            directoryPath
        );


        if (
            !directory.exists()
        ) {
            continue;
        }


        directoriesToWatch.append(
            directory.absolutePath()
        );


        QDirIterator iterator(
            directory.absolutePath(),
            QStringList()
                << QStringLiteral(
                       "*.json"
                   ),
            QDir::Files,
            QDirIterator::Subdirectories
        );


        while (
            iterator.hasNext()
        ) {

            const QString manifestPath =
                iterator.next();


            const QVariantMap app =
                loadManifest(
                    manifestPath
                );


            if (
                app.isEmpty()
            ) {
                continue;
            }


            applications.insert(
                app.value(
                    QStringLiteral(
                        "id"
                    )
                ).toString(),
                app
            );


            filesToWatch.append(
                manifestPath
            );
        }
    }


    QVariantList next;


    for (
        auto iterator =
            applications.cbegin();

        iterator !=
        applications.cend();

        ++iterator
    ) {

        next.append(
            iterator.value()
        );
    }


    std::sort(
        next.begin(),
        next.end(),

        [](
            const QVariant &left,
            const QVariant &right
        ) {

            const QVariantMap a =
                left.toMap();

            const QVariantMap b =
                right.toMap();


            const int ao =
                a.value(
                    QStringLiteral(
                        "order"
                    )
                ).toInt();


            const int bo =
                b.value(
                    QStringLiteral(
                        "order"
                    )
                ).toInt();


            if (
                ao != bo
            ) {
                return
                    ao < bo;
            }


            return
                a.value(
                    QStringLiteral(
                        "title"
                    )
                ).toString()
                <
                b.value(
                    QStringLiteral(
                        "title"
                    )
                ).toString();
        }
    );


    // Rebuild file-system watching.

    if (
        !m_watcher
            .files()
            .isEmpty()
    ) {

        m_watcher.removePaths(
            m_watcher.files()
        );
    }


    if (
        !m_watcher
            .directories()
            .isEmpty()
    ) {

        m_watcher.removePaths(
            m_watcher.directories()
        );
    }


    if (
        !directoriesToWatch.isEmpty()
    ) {

        m_watcher.addPaths(
            directoriesToWatch
        );
    }


    if (
        !filesToWatch.isEmpty()
    ) {

        m_watcher.addPaths(
            filesToWatch
        );
    }


    if (
        next == m_apps
    ) {
        return;
    }


    m_apps =
        next;


    emit appsChanged();
}


QVariantMap AppRegistry::appById(
    const QString &id
) const
{
    for (
        const QVariant &value :
        m_apps
    ) {

        const QVariantMap app =
            value.toMap();


        if (
            app.value(
                QStringLiteral(
                    "id"
                )
            ).toString()
            ==
            id
        ) {
            return app;
        }
    }


    return {};
}
