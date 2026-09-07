#pragma once

#include <QObject>
#include <QFileSystemWatcher>
#include <QVariantList>
#include <QVariantMap>


class AppRegistry final : public QObject
{
    Q_OBJECT

    Q_PROPERTY(
        QVariantList apps
        READ apps
        NOTIFY appsChanged
    )


public:

    explicit AppRegistry(
        QObject *parent = nullptr
    );


    QVariantList apps() const;


    Q_INVOKABLE void reload();

    Q_INVOKABLE QVariantMap appById(
        const QString &id
    ) const;


signals:

    void appsChanged();


private:

    QStringList manifestDirectories() const;

    QVariantMap loadManifest(
        const QString &path
    ) const;


    QVariantList m_apps;

    QFileSystemWatcher m_watcher;
};
