#include "AppRegistry.h"

#include <QDir>
#include <QDirIterator>
#include <QFile>
#include <QFileInfo>
#include <QHash>

#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>

#include <QSaveFile>
#include <QTimer>
#include <QUrl>

#include <algorithm>


// ============================================================
// Constructor
// ============================================================

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


    loadLayout();
    reload();
}


// ============================================================
// Public data
// ============================================================

QVariantList AppRegistry::apps() const
{
    return m_apps;
}


QVariantList AppRegistry::homeApps() const
{
    return appsForOrder(
        m_homeOrder
    );
}


QVariantList AppRegistry::dockApps() const
{
    return appsForOrder(
        m_dockOrder
    );
}


// ============================================================
// Layout storage path
// ============================================================

QString AppRegistry::layoutPath() const
{
    QString base;


    if (
        QDir(
            QStringLiteral(
                "/data/home/luma"
            )
        ).exists()
    ) {

        base =
            QStringLiteral(
                "/data/home/luma/.config/luma"
            );

    } else {

        base =
            QDir::home().filePath(
                QStringLiteral(
                    ".config/luma"
                )
            );
    }


    QDir().mkpath(
        base
    );


    return
        QDir(base).filePath(
            QStringLiteral(
                "home.json"
            )
        );
}


// ============================================================
// Manifest directories
// ============================================================

QStringList AppRegistry::manifestDirectories() const
{
    QStringList result;


    auto addDirectory =
        [&result](
            const QString &path
        ) {

            if (
                !path.isEmpty() &&
                !result.contains(path)
            ) {

                result.append(
                    QDir(path)
                        .absolutePath()
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


    addDirectory(
        QStringLiteral(
            "/usr/share/luma/apps"
        )
    );


    if (
        QDir(
            QStringLiteral(
                "/data/home/luma"
            )
        ).exists()
    ) {

        const QString path =
            QStringLiteral(
                "/data/home/luma/.local/share/luma/apps"
            );


        QDir().mkpath(
            path
        );


        addDirectory(
            path
        );
    }


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


    const QString extra =
        qEnvironmentVariable(
            "LUMA_APP_DIR"
        );


    if (
        !extra.isEmpty()
    ) {

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


// ============================================================
// Manifest parser
// ============================================================

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


    if (
        title.isEmpty()
    ) {

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
            if (
                value.isEmpty()
            ) {

                return {};
            }


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


    app["id"] =
        id;


    app["title"] =
        title;


    app["glyph"] =
        object
            .value(
                QStringLiteral(
                    "glyph"
                )
            )
            .toString(
                title.left(1)
            );


    app["accent"] =
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


    app["order"] =
        object
            .value(
                QStringLiteral(
                    "order"
                )
            )
            .toInt(
                1000
            );


    app["dock"] =
        object
            .value(
                QStringLiteral(
                    "dock"
                )
            )
            .toBool(
                false
            );


    app["home"] =
        object
            .value(
                QStringLiteral(
                    "home"
                )
            )
            .toBool(
                true
            );


    app["entryUrl"] =
        QUrl::fromLocalFile(
            entryPath
        ).toString();


    app["iconUrl"] =
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


    app["manifest"] =
        manifestInfo
            .absoluteFilePath();


    return app;
}


// ============================================================
// Layout load/save
// ============================================================

void AppRegistry::loadLayout()
{
    QFile file(
        layoutPath()
    );


    if (
        !file.exists()
    ) {

        m_hasSavedLayout =
            false;

        return;
    }


    if (
        !file.open(
            QIODevice::ReadOnly
        )
    ) {

        m_hasSavedLayout =
            false;

        return;
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

        m_hasSavedLayout =
            false;

        return;
    }


    const QJsonObject object =
        document.object();


    auto readArray =
        [&object](
            const QString &name
        ) {

            QStringList result;


            const QJsonArray array =
                object
                    .value(name)
                    .toArray();


            for (
                const QJsonValue &value :
                array
            ) {

                const QString id =
                    value
                        .toString()
                        .trimmed();


                if (
                    !id.isEmpty() &&
                    !result.contains(id)
                ) {

                    result.append(
                        id
                    );
                }
            }


            return result;
        };


    m_homeOrder =
        readArray(
            QStringLiteral(
                "home"
            )
        );


    m_dockOrder =
        readArray(
            QStringLiteral(
                "dock"
            )
        );


    m_hasSavedLayout =
        true;
}


bool AppRegistry::saveLayout()
{
    QJsonObject root;


    root[
        QStringLiteral(
            "version"
        )
    ] = 1;


    QJsonArray home;


    for (
        const QString &id :
        m_homeOrder
    ) {

        home.append(
            id
        );
    }


    QJsonArray dock;


    for (
        const QString &id :
        m_dockOrder
    ) {

        dock.append(
            id
        );
    }


    root[
        QStringLiteral(
            "home"
        )
    ] = home;


    root[
        QStringLiteral(
            "dock"
        )
    ] = dock;


    QSaveFile file(
        layoutPath()
    );


    if (
        !file.open(
            QIODevice::WriteOnly
        )
    ) {

        return false;
    }


    file.write(
        QJsonDocument(root)
            .toJson(
                QJsonDocument::Indented
            )
    );


    if (
        !file.commit()
    ) {

        return false;
    }


    m_hasSavedLayout =
        true;


    return true;
}


// ============================================================
// Default layout
// ============================================================

void AppRegistry::seedDefaultLayout()
{
    m_homeOrder.clear();
    m_dockOrder.clear();


    // First build the dock.
    //
    // Maximum of four apps.

    for (
        const QVariant &value :
        m_apps
    ) {

        const QVariantMap app =
            value.toMap();


        if (
            app.value(
                "dock"
            ).toBool()
            &&
            m_dockOrder.size() < 4
        ) {

            m_dockOrder.append(
                app.value(
                    "id"
                ).toString()
            );
        }
    }


    // Everything else that belongs on Home.

    for (
        const QVariant &value :
        m_apps
    ) {

        const QVariantMap app =
            value.toMap();


        const QString id =
            app.value(
                "id"
            ).toString();


        if (
            app.value(
                "home"
            ).toBool()
            &&
            !m_dockOrder.contains(id)
        ) {

            m_homeOrder.append(
                id
            );
        }
    }
}


// ============================================================
// Helpers
// ============================================================

QStringList AppRegistry::cleanOrder(
    const QStringList &input
) const
{
    QStringList result;


    for (
        const QString &id :
        input
    ) {

        if (
            id.isEmpty() ||
            result.contains(id) ||
            appById(id).isEmpty()
        ) {

            continue;
        }


        result.append(
            id
        );
    }


    return result;
}


QVariantList AppRegistry::appsForOrder(
    const QStringList &order
) const
{
    QVariantList result;


    for (
        const QString &id :
        order
    ) {

        const QVariantMap app =
            appById(
                id
            );


        if (
            !app.isEmpty()
        ) {

            result.append(
                app
            );
        }
    }


    return result;
}


// ============================================================
// Reconcile installed apps with saved layout
// ============================================================

bool AppRegistry::reconcileLayout()
{
    const QStringList beforeHome =
        m_homeOrder;

    const QStringList beforeDock =
        m_dockOrder;


    if (
        !m_hasSavedLayout
    ) {

        seedDefaultLayout();

        return true;
    }


    // Dock wins if old data accidentally contains an app
    // in both places.

    m_dockOrder =
        cleanOrder(
            m_dockOrder
        );


    while (
        m_dockOrder.size() > 4
    ) {

        m_dockOrder.removeLast();
    }


    QStringList cleanHome =
        cleanOrder(
            m_homeOrder
        );


    for (
        const QString &id :
        m_dockOrder
    ) {

        cleanHome.removeAll(
            id
        );
    }


    m_homeOrder =
        cleanHome;


    // Newly installed applications are appended to Home.
    //
    // We intentionally do NOT modify a user's dock when
    // a new application is installed.

    for (
        const QVariant &value :
        m_apps
    ) {

        const QVariantMap app =
            value.toMap();


        const QString id =
            app.value(
                "id"
            ).toString();


        if (
            !app.value(
                "home"
            ).toBool()
        ) {

            continue;
        }


        if (
            m_homeOrder.contains(id) ||
            m_dockOrder.contains(id)
        ) {

            continue;
        }


        m_homeOrder.append(
            id
        );
    }


    return
        beforeHome != m_homeOrder ||
        beforeDock != m_dockOrder;
}


// ============================================================
// Scan applications
// ============================================================

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
                    "id"
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
                    "order"
                ).toInt();


            const int bo =
                b.value(
                    "order"
                ).toInt();


            if (
                ao != bo
            ) {

                return
                    ao < bo;
            }


            return
                a.value(
                    "title"
                ).toString()
                <
                b.value(
                    "title"
                ).toString();
        }
    );


    const bool appsChangedNow =
        next != m_apps;


    m_apps =
        next;


    const bool layoutChangedNow =
        reconcileLayout();


    if (
        layoutChangedNow
    ) {

        saveLayout();
    }


    // Rebuild filesystem watcher.

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
        !directoriesToWatch
            .isEmpty()
    ) {

        m_watcher.addPaths(
            directoriesToWatch
        );
    }


    if (
        !filesToWatch
            .isEmpty()
    ) {

        m_watcher.addPaths(
            filesToWatch
        );
    }


    if (
        appsChangedNow
    ) {

        emit appsChanged();
    }


    if (
        layoutChangedNow ||
        appsChangedNow
    ) {

        emit layoutChanged();
    }
}


// ============================================================
// Find app
// ============================================================

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
                "id"
            ).toString()
            ==
            id
        ) {

            return app;
        }
    }


    return {};
}


// ============================================================
// Reorder Home
// ============================================================

bool AppRegistry::setHomeOrder(
    const QVariantList &ids
)
{
    QStringList requested;


    for (
        const QVariant &value :
        ids
    ) {

        const QString id =
            value.toString();


        if (
            m_homeOrder.contains(id) &&
            !requested.contains(id)
        ) {

            requested.append(
                id
            );
        }
    }


    // Keep anything that the caller did not send.

    for (
        const QString &id :
        m_homeOrder
    ) {

        if (
            !requested.contains(id)
        ) {

            requested.append(
                id
            );
        }
    }


    if (
        requested ==
        m_homeOrder
    ) {

        return true;
    }


    m_homeOrder =
        requested;


    const bool ok =
        saveLayout();


    emit layoutChanged();


    return ok;
}


// ============================================================
// Reorder Dock
// ============================================================

bool AppRegistry::setDockOrder(
    const QVariantList &ids
)
{
    QStringList requested;


    for (
        const QVariant &value :
        ids
    ) {

        const QString id =
            value.toString();


        if (
            m_dockOrder.contains(id) &&
            !requested.contains(id)
        ) {

            requested.append(
                id
            );
        }
    }


    for (
        const QString &id :
        m_dockOrder
    ) {

        if (
            !requested.contains(id)
        ) {

            requested.append(
                id
            );
        }
    }


    while (
        requested.size() > 4
    ) {

        requested.removeLast();
    }


    if (
        requested ==
        m_dockOrder
    ) {

        return true;
    }


    m_dockOrder =
        requested;


    const bool ok =
        saveLayout();


    emit layoutChanged();


    return ok;
}


// ============================================================
// Home -> Dock
//
// If dock has four apps, dropping onto a position swaps the
// displaced app back into the original Home position.
// ============================================================

bool AppRegistry::moveAppToDock(
    const QString &id,
    int index
)
{
    if (
        appById(id).isEmpty()
    ) {

        return false;
    }


    // Already docked = reorder.

    const int existingDock =
        m_dockOrder.indexOf(
            id
        );


    if (
        existingDock >= 0
    ) {

        QStringList reordered =
            m_dockOrder;


        reordered.removeAt(
            existingDock
        );


        index =
            qBound(
                0,
                index,
                reordered.size()
            );


        reordered.insert(
            index,
            id
        );


        m_dockOrder =
            reordered;


        const bool ok =
            saveLayout();


        emit layoutChanged();


        return ok;
    }


    const int oldHomeIndex =
        m_homeOrder.indexOf(
            id
        );


    m_homeOrder.removeAll(
        id
    );


    if (
        m_dockOrder.size() < 4
    ) {

        index =
            qBound(
                0,
                index,
                m_dockOrder.size()
            );


        m_dockOrder.insert(
            index,
            id
        );

    } else {

        index =
            qBound(
                0,
                index,
                m_dockOrder.size() - 1
            );


        const QString displaced =
            m_dockOrder.at(
                index
            );


        m_dockOrder[index] =
            id;


        const int homeIndex =
            oldHomeIndex >= 0
                ? qBound(
                      0,
                      oldHomeIndex,
                      m_homeOrder.size()
                  )
                : m_homeOrder.size();


        m_homeOrder.insert(
            homeIndex,
            displaced
        );
    }


    const bool ok =
        saveLayout();


    emit layoutChanged();


    return ok;
}


// ============================================================
// Dock -> Home
// ============================================================

bool AppRegistry::moveAppToHome(
    const QString &id,
    int index
)
{
    if (
        appById(id).isEmpty()
    ) {

        return false;
    }


    const int existingHome =
        m_homeOrder.indexOf(
            id
        );


    if (
        existingHome >= 0
    ) {

        QStringList reordered =
            m_homeOrder;


        reordered.removeAt(
            existingHome
        );


        index =
            qBound(
                0,
                index,
                reordered.size()
            );


        reordered.insert(
            index,
            id
        );


        m_homeOrder =
            reordered;


        const bool ok =
            saveLayout();


        emit layoutChanged();


        return ok;
    }


    m_dockOrder.removeAll(
        id
    );


    index =
        qBound(
            0,
            index,
            m_homeOrder.size()
        );


    m_homeOrder.insert(
        index,
        id
    );


    const bool ok =
        saveLayout();


    emit layoutChanged();


    return ok;
}


// ============================================================
// Reset Home layout
// ============================================================

void AppRegistry::resetLayout()
{
    seedDefaultLayout();

    saveLayout();

    emit layoutChanged();
}
