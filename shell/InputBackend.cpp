#include "InputBackend.h"

#include <QCoreApplication>
#include <QGuiApplication>
#include <QInputMethodEvent>
#include <QInputMethodQueryEvent>
#include <QKeyEvent>


InputBackend::InputBackend(
    QObject *parent
)
    : QObject(parent)
{
    auto *app =
        qobject_cast<QGuiApplication *>(
            QCoreApplication::instance()
        );


    if (!app)
        return;


    connect(
        app,
        &QGuiApplication::focusObjectChanged,
        this,
        &InputBackend::handleFocusObjectChanged
    );


    handleFocusObjectChanged(
        app->focusObject()
    );
}


bool InputBackend::inputActive() const
{
    return m_inputActive;
}


void InputBackend::show()
{
    auto *app =
        qobject_cast<QGuiApplication *>(
            QCoreApplication::instance()
        );


    if (
        app &&
        app->focusObject()
    ) {
        m_target =
            app->focusObject();
    }


    if (m_target)
        setInputActive(true);
}


void InputBackend::hide()
{
    setInputActive(false);
}


void InputBackend::typeText(
    const QString &text
)
{
    QObject *target =
        targetObject();


    if (!target)
        return;


    /*
     * InputMethodEvent works with normal QML text fields
     * and gives WebEngine a proper text commit path.
     */

    QInputMethodEvent event;

    event.setCommitString(
        text
    );


    QCoreApplication::sendEvent(
        target,
        &event
    );
}


void InputBackend::backspace()
{
    sendKey(
        Qt::Key_Backspace
    );
}


void InputBackend::enter()
{
    sendKey(
        Qt::Key_Return,
        QStringLiteral("\n")
    );
}


void InputBackend::tab()
{
    sendKey(
        Qt::Key_Tab,
        QStringLiteral("\t")
    );
}


void InputBackend::left()
{
    sendKey(
        Qt::Key_Left
    );
}


void InputBackend::right()
{
    sendKey(
        Qt::Key_Right
    );
}


void InputBackend::handleFocusObjectChanged(
    QObject *object
)
{
    if (
        acceptsInput(
            object
        )
    ) {
        m_target = object;

        setInputActive(
            true
        );

        return;
    }


    /*
     * Keep the previous target around.
     *
     * Our keyboard buttons themselves should never steal the
     * text destination.
     */

    setInputActive(
        false
    );
}


bool InputBackend::acceptsInput(
    QObject *object
) const
{
    if (!object)
        return false;


    QInputMethodQueryEvent query(
        Qt::ImEnabled
    );


    QCoreApplication::sendEvent(
        object,
        &query
    );


    return query
        .value(
            Qt::ImEnabled
        )
        .toBool();
}


QObject *InputBackend::targetObject()
{
    if (m_target)
        return m_target.data();


    auto *app =
        qobject_cast<QGuiApplication *>(
            QCoreApplication::instance()
        );


    if (
        app &&
        app->focusObject()
    ) {
        m_target =
            app->focusObject();
    }


    return m_target.data();
}


void InputBackend::setInputActive(
    bool active
)
{
    if (
        m_inputActive ==
        active
    )
        return;


    m_inputActive =
        active;


    emit inputActiveChanged();
}


void InputBackend::sendKey(
    int key,
    const QString &text
)
{
    QObject *target =
        targetObject();


    if (!target)
        return;


    QKeyEvent press(
        QEvent::KeyPress,
        key,
        Qt::NoModifier,
        text
    );


    QCoreApplication::sendEvent(
        target,
        &press
    );


    QKeyEvent release(
        QEvent::KeyRelease,
        key,
        Qt::NoModifier,
        text
    );


    QCoreApplication::sendEvent(
        target,
        &release
    );
}
