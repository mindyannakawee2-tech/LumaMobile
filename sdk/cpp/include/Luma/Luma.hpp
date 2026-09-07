#pragma once

#include <cstdint>
#include <string>
#include <vector>


#define LUMA_SDK_VERSION "0.2.0"


namespace Luma {


enum class ErrorCode
{
    None = 0,

    NotAvailable,
    ConnectionFailed,
    ProtocolError,
    AbiMismatch,

    PermissionDenied,
    NotFound,
    InvalidArgument,

    Unsupported,
    Internal
};


template<typename T>
struct Result
{
    T value {};

    ErrorCode error =
        ErrorCode::None;

    std::string message;


    bool ok() const
    {
        return
            error ==
            ErrorCode::None;
    }


    explicit operator bool() const
    {
        return ok();
    }
};


template<>
struct Result<void>
{
    ErrorCode error =
        ErrorCode::None;

    std::string message;


    bool ok() const
    {
        return
            error ==
            ErrorCode::None;
    }


    explicit operator bool() const
    {
        return ok();
    }
};


struct AppInfo
{
    std::string id;
    std::string name;
    std::string version;

    std::vector<std::string>
        permissions;
};


struct Notification
{
    std::uint64_t id = 0;

    std::string appId;
    std::string title;
    std::string body;
};


namespace System
{
    Result<std::string> ping();

    Result<std::string>
    frameworkVersion();

    Result<std::string>
    capabilities();

    Result<std::string>
    info();

    Result<std::string>
    uptime();

    Result<std::string>
    memory();
}


namespace Power
{
    Result<void> shutdown();
    Result<void> reboot();
}


namespace Services
{
    Result<std::string> ping();

    Result<std::string>
    version();

    Result<std::string>
    capabilities();

    Result<std::string>
    health();

    Result<std::string>
    deviceInfo();

    Result<std::string>
    session();
}


namespace Applications
{
    Result<std::vector<AppInfo>>
    list();

    Result<AppInfo>
    get(
        const std::string &appId
    );

    Result<void>
    registerApp(
        const AppInfo &app
    );
}


namespace Permissions
{
    Result<bool>
    check(
        const std::string &appId,
        const std::string &permission
    );
}


namespace Notifications
{
    Result<void>
    post(
        const std::string &appId,
        const std::string &title,
        const std::string &body
    );

    Result<std::vector<Notification>>
    list();
}


class Application
{
public:

    Application(
        std::string id,
        std::string name,
        std::string version,
        std::vector<std::string>
            permissions = {}
    );


    const std::string &
    id() const;


    const std::string &
    name() const;


    const std::string &
    version() const;


    const std::vector<std::string> &
    declaredPermissions() const;


    Result<bool>
    isRegistered() const;


    Result<void>
    registerWithLMS() const;


    Result<bool>
    hasPermission(
        const std::string &permission
    ) const;


    Result<void>
    notify(
        const std::string &title,
        const std::string &body
    ) const;


private:

    std::string m_id;
    std::string m_name;
    std::string m_version;

    std::vector<std::string>
        m_permissions;
};


}
