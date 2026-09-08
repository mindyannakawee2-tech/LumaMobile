#pragma once

#include <QObject>
#include <QFileSystemWatcher>
#include <QStringList>
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

    Q_PROPERTY(
        QVariantList homeApps
        READ homeApps
        NOTIFY layoutChanged
    )

    Q_PROPERTY(
        QVariantList dockApps
        READ dockApps
        NOTIFY layoutChanged
    )

    Q_PROPERTY(
        QString layoutPath
        READ layoutPath
        CONSTANT
    )


public:

    explicit AppRegistry(
        QObject *parent = nullptr
    );


    QVariantList apps() const;

    QVariantList homeApps() const;
    QVariantList dockApps() const;

    QString layoutPath() const;


    Q_INVOKABLE void reload();

    Q_INVOKABLE QVariantMap appById(
        const QString &id
    ) const;


    Q_INVOKABLE bool setHomeOrder(
        const QVariantList &ids
    );

    Q_INVOKABLE bool setDockOrder(
        const QVariantList &ids
    );


    Q_INVOKABLE bool moveAppToDock(
        const QString &id,
        int index
    );

    Q_INVOKABLE bool moveAppToHome(
        const QString &id,
        int index
    );


    Q_INVOKABLE bool saveLayout();

    Q_INVOKABLE void resetLayout();


signals:

    void appsChanged();
    void layoutChanged();


private:

    QStringList manifestDirectories() const;

    QVariantMap loadManifest(
        const QString &path
    ) const;


    void loadLayout();
    void seedDefaultLayout();

    bool reconcileLayout();

    QVariantList appsForOrder(
        const QStringList &order
    ) const;

    QStringList cleanOrder(
        const QStringList &input
    ) const;


    QVariantList m_apps;

    QStringList m_homeOrder;
    QStringList m_dockOrder;

    bool m_hasSavedLayout = false;

    QFileSystemWatcher m_watcher;
};
