#pragma once

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <QString>

class SystemBackend : public QObject
{
    Q_OBJECT

public:
    explicit SystemBackend(QObject *parent = nullptr);

    Q_INVOKABLE QVariantMap status();

    Q_INVOKABLE bool wifiEnabled();
    Q_INVOKABLE bool setWifiEnabled(bool enabled);

    Q_INVOKABLE bool bluetoothEnabled();
    Q_INVOKABLE bool setBluetoothEnabled(bool enabled);

    Q_INVOKABLE int batteryPercent();

    Q_INVOKABLE int brightnessPercent();
    Q_INVOKABLE bool setBrightnessPercent(int value);

    Q_INVOKABLE int volumePercent();
    Q_INVOKABLE bool setVolumePercent(int value);

    Q_INVOKABLE QVariantMap storageInfo();

    Q_INVOKABLE QString homePath();
    Q_INVOKABLE QString picturesPath();
    Q_INVOKABLE QString musicPath();
    Q_INVOKABLE QString downloadsPath();

    Q_INVOKABLE QVariantList listDirectory(const QString &path);
    Q_INVOKABLE QVariantList listImages(const QString &path);
    Q_INVOKABLE QVariantList listAudio(const QString &path);

    Q_INVOKABLE QString parentPath(const QString &path);
    Q_INVOKABLE QString fileUrl(const QString &path);

    Q_INVOKABLE bool openPath(const QString &path);

    Q_INVOKABLE QVariantMap createFolder(
        const QString &parent,
        const QString &name
    );

    Q_INVOKABLE QVariantMap renamePath(
        const QString &path,
        const QString &newName
    );

    Q_INVOKABLE QVariantList listLpkPackages();
    Q_INVOKABLE QVariantMap installLpk(const QString &path);

    Q_INVOKABLE bool cellularAvailable();
    Q_INVOKABLE QVariantMap dial(const QString &number);
    Q_INVOKABLE QVariantMap hangupCall();

    Q_INVOKABLE QVariantMap sendSms(
        const QString &number,
        const QString &text
    );

private:
    QString m_activeCall;

    struct Result {
        int code = -1;
        QString out;
        QString err;
    };

    Result run(
        const QString &program,
        const QStringList &arguments,
        int timeout = 10000
    );

    QString executable(const QString &name);
    QString firstModem();
    QString humanBytes(quint64 value);
};
