#pragma once

#include <QObject>
#include <QPointer>
#include <QString>

class InputBackend final : public QObject
{
    Q_OBJECT

    Q_PROPERTY(
        bool inputActive
        READ inputActive
        NOTIFY inputActiveChanged
    )

public:

    explicit InputBackend(
        QObject *parent = nullptr
    );

    bool inputActive() const;


    Q_INVOKABLE void show();
    Q_INVOKABLE void hide();

    Q_INVOKABLE void typeText(
        const QString &text
    );

    Q_INVOKABLE void backspace();
    Q_INVOKABLE void enter();
    Q_INVOKABLE void tab();

    Q_INVOKABLE void left();
    Q_INVOKABLE void right();


signals:

    void inputActiveChanged();


private slots:

    void handleFocusObjectChanged(
        QObject *object
    );


private:

    bool acceptsInput(
        QObject *object
    ) const;

    QObject *targetObject();

    void setInputActive(
        bool active
    );

    void sendKey(
        int key,
        const QString &text = QString()
    );


    QPointer<QObject> m_target;

    bool m_inputActive = false;
};
