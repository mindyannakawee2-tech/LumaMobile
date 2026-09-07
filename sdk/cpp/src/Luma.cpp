#include <Luma/Luma.hpp>

#include <sys/socket.h>
#include <sys/un.h>

#include <cerrno>
#include <cstring>
#include <sstream>
#include <string>
#include <utility>
#include <unistd.h>
#include <vector>


namespace {


/* ============================================================
 * Framework protocol
 * ============================================================ */

constexpr std::uint32_t
FW_MAGIC =
    0x4C554D41u;

constexpr std::uint16_t
FW_ABI_MAJOR =
    2;

constexpr std::uint16_t
FW_ABI_MINOR =
    0;

constexpr const char *
FW_SOCKET =
    "/run/luma/framework.sock";

constexpr std::size_t
FW_PAYLOAD_MAX =
    2048;


struct FrameworkMessage
{
    std::uint32_t magic;

    std::uint16_t abiMajor;
    std::uint16_t abiMinor;

    std::uint16_t type;
    std::uint16_t command;

    std::uint32_t requestId;

    std::int32_t status;

    std::uint32_t payloadLength;

    char payload[FW_PAYLOAD_MAX];
};


/* Framework commands */

constexpr std::uint16_t
FW_CMD_PING =
    0x0001;

constexpr std::uint16_t
FW_CMD_VERSION =
    0x0002;

constexpr std::uint16_t
FW_CMD_CAPABILITIES =
    0x0003;

constexpr std::uint16_t
FW_CMD_INFO =
    0x0101;

constexpr std::uint16_t
FW_CMD_UPTIME =
    0x0102;

constexpr std::uint16_t
FW_CMD_MEMORY =
    0x0103;

constexpr std::uint16_t
FW_CMD_SHUTDOWN =
    0x0201;

constexpr std::uint16_t
FW_CMD_REBOOT =
    0x0202;


/* ============================================================
 * LMS protocol
 * ============================================================ */

constexpr std::uint32_t
LMS_MAGIC =
    0x4C4D5353u;

constexpr std::uint16_t
LMS_ABI_MAJOR =
    2;

constexpr std::uint16_t
LMS_ABI_MINOR =
    0;

constexpr const char *
LMS_SOCKET =
    "/run/lms/lms.sock";

constexpr std::size_t
LMS_PAYLOAD_MAX =
    4096;


struct LmsMessage
{
    std::uint32_t magic;

    std::uint16_t abiMajor;
    std::uint16_t abiMinor;

    std::uint16_t type;
    std::uint16_t command;

    std::uint32_t requestId;

    std::int32_t status;

    std::uint32_t payloadLength;

    char payload[LMS_PAYLOAD_MAX];
};


/* LMS commands */

constexpr std::uint16_t
LMS_CMD_PING =
    0x0001;

constexpr std::uint16_t
LMS_CMD_VERSION =
    0x0002;

constexpr std::uint16_t
LMS_CMD_CAPABILITIES =
    0x0003;

constexpr std::uint16_t
LMS_CMD_HEALTH =
    0x0004;

constexpr std::uint16_t
LMS_CMD_DEVICE_INFO =
    0x0101;

constexpr std::uint16_t
LMS_CMD_SESSION =
    0x0102;

constexpr std::uint16_t
LMS_CMD_APP_REGISTER =
    0x0201;

constexpr std::uint16_t
LMS_CMD_APP_LIST =
    0x0202;

constexpr std::uint16_t
LMS_CMD_APP_GET =
    0x0203;

constexpr std::uint16_t
LMS_CMD_PERMISSION_CHECK =
    0x0301;

constexpr std::uint16_t
LMS_CMD_NOTIFY_POST =
    0x0401;

constexpr std::uint16_t
LMS_CMD_NOTIFY_LIST =
    0x0402;


static std::uint32_t
requestCounter = 1;


/* ============================================================
 * Helpers
 * ============================================================ */

Luma::ErrorCode
mapStatus(
    std::int32_t status
)
{
    switch (status)
    {
        case 0:
            return
                Luma::ErrorCode::None;

        case -2:
            return
                Luma::ErrorCode::AbiMismatch;

        case -4:
            return
                Luma::ErrorCode::Internal;

        case -5:
            return
                Luma::ErrorCode::Unsupported;

        case -6:
            return
                Luma::ErrorCode::PermissionDenied;

        case -7:
            return
                Luma::ErrorCode::NotFound;

        case -8:
            return
                Luma::ErrorCode::InvalidArgument;

        case -9:
            return
                Luma::ErrorCode::NotAvailable;

        default:
            return
                Luma::ErrorCode::ProtocolError;
    }
}


std::vector<std::string>
split(
    const std::string &text,
    char delimiter
)
{
    std::vector<std::string>
        output;

    std::stringstream stream(text);

    std::string item;


    while (
        std::getline(
            stream,
            item,
            delimiter
        )
    )
    {
        output.push_back(
            item
        );
    }


    return output;
}


std::string
join(
    const std::vector<std::string> &values,
    char delimiter
)
{
    std::string output;


    for (
        std::size_t i = 0;
        i < values.size();
        ++i
    )
    {
        if (i != 0)
            output += delimiter;

        output += values[i];
    }


    return output;
}


/* ============================================================
 * Framework request
 * ============================================================ */

Luma::Result<std::string>
frameworkRequest(
    std::uint16_t command,
    const std::string &payload = {}
)
{
    Luma::Result<std::string>
        result;


    if (
        payload.size() >=
        FW_PAYLOAD_MAX
    )
    {
        result.error =
            Luma::ErrorCode::
                InvalidArgument;

        result.message =
            "Framework payload too large";

        return result;
    }


    int fd =
        socket(
            AF_UNIX,
            SOCK_SEQPACKET,
            0
        );


    if (fd < 0)
    {
        result.error =
            Luma::ErrorCode::
                ConnectionFailed;

        result.message =
            std::strerror(errno);

        return result;
    }


    sockaddr_un addr {};

    addr.sun_family =
        AF_UNIX;


    std::strncpy(
        addr.sun_path,
        FW_SOCKET,
        sizeof(addr.sun_path) - 1
    );


    if (
        connect(
            fd,
            reinterpret_cast<
                sockaddr *
            >(&addr),
            sizeof(addr)
        ) != 0
    )
    {
        result.error =
            Luma::ErrorCode::
                NotAvailable;

        result.message =
            std::strerror(errno);

        close(fd);

        return result;
    }


    FrameworkMessage request {};

    request.magic =
        FW_MAGIC;

    request.abiMajor =
        FW_ABI_MAJOR;

    request.abiMinor =
        FW_ABI_MINOR;

    request.type = 1;

    request.command =
        command;

    request.requestId =
        requestCounter++;


    if (!payload.empty())
    {
        std::memcpy(
            request.payload,
            payload.data(),
            payload.size()
        );

        request.payloadLength =
            static_cast<std::uint32_t>(
                payload.size()
            );
    }


    ssize_t sent =
        send(
            fd,
            &request,
            sizeof(request),
            0
        );


    if (
        sent !=
        static_cast<ssize_t>(
            sizeof(request)
        )
    )
    {
        result.error =
            Luma::ErrorCode::
                ConnectionFailed;

        result.message =
            "failed to send Framework request";

        close(fd);

        return result;
    }


    FrameworkMessage response {};


    ssize_t received =
        recv(
            fd,
            &response,
            sizeof(response),
            0
        );


    close(fd);


    if (received <= 0)
    {
        result.error =
            Luma::ErrorCode::
                ConnectionFailed;

        result.message =
            "Framework returned no response";

        return result;
    }


    if (
        response.magic !=
        FW_MAGIC
    )
    {
        result.error =
            Luma::ErrorCode::
                ProtocolError;

        result.message =
            "invalid Framework response magic";

        return result;
    }


    if (
        response.abiMajor !=
        FW_ABI_MAJOR
    )
    {
        result.error =
            Luma::ErrorCode::
                AbiMismatch;

        result.message =
            "Framework ABI mismatch";

        return result;
    }


    if (
        response.payloadLength >
        FW_PAYLOAD_MAX
    )
    {
        result.error =
            Luma::ErrorCode::
                ProtocolError;

        result.message =
            "invalid Framework response";

        return result;
    }


    result.value =
        std::string(
            response.payload,
            response.payload
                + response.payloadLength
        );


    if (
        response.status != 0
    )
    {
        result.error =
            mapStatus(
                response.status
            );

        result.message =
            result.value;
    }


    return result;
}


/* ============================================================
 * LMS request
 * ============================================================ */

Luma::Result<std::string>
lmsRequest(
    std::uint16_t command,
    const std::string &payload = {}
)
{
    Luma::Result<std::string>
        result;


    if (
        payload.size() >=
        LMS_PAYLOAD_MAX
    )
    {
        result.error =
            Luma::ErrorCode::
                InvalidArgument;

        result.message =
            "LMS payload too large";

        return result;
    }


    int fd =
        socket(
            AF_UNIX,
            SOCK_SEQPACKET,
            0
        );


    if (fd < 0)
    {
        result.error =
            Luma::ErrorCode::
                ConnectionFailed;

        result.message =
            std::strerror(errno);

        return result;
    }


    sockaddr_un addr {};

    addr.sun_family =
        AF_UNIX;


    std::strncpy(
        addr.sun_path,
        LMS_SOCKET,
        sizeof(addr.sun_path) - 1
    );


    if (
        connect(
            fd,
            reinterpret_cast<
                sockaddr *
            >(&addr),
            sizeof(addr)
        ) != 0
    )
    {
        result.error =
            Luma::ErrorCode::
                NotAvailable;

        result.message =
            std::strerror(errno);

        close(fd);

        return result;
    }


    LmsMessage request {};

    request.magic =
        LMS_MAGIC;

    request.abiMajor =
        LMS_ABI_MAJOR;

    request.abiMinor =
        LMS_ABI_MINOR;

    request.type = 1;

    request.command =
        command;

    request.requestId =
        requestCounter++;


    if (!payload.empty())
    {
        std::memcpy(
            request.payload,
            payload.data(),
            payload.size()
        );

        request.payloadLength =
            static_cast<std::uint32_t>(
                payload.size()
            );
    }


    ssize_t sent =
        send(
            fd,
            &request,
            sizeof(request),
            0
        );


    if (
        sent !=
        static_cast<ssize_t>(
            sizeof(request)
        )
    )
    {
        result.error =
            Luma::ErrorCode::
                ConnectionFailed;

        result.message =
            "failed to send LMS request";

        close(fd);

        return result;
    }


    LmsMessage response {};


    ssize_t received =
        recv(
            fd,
            &response,
            sizeof(response),
            0
        );


    close(fd);


    if (received <= 0)
    {
        result.error =
            Luma::ErrorCode::
                ConnectionFailed;

        result.message =
            "LMS returned no response";

        return result;
    }


    if (
        response.magic !=
        LMS_MAGIC
    )
    {
        result.error =
            Luma::ErrorCode::
                ProtocolError;

        result.message =
            "invalid LMS response magic";

        return result;
    }


    if (
        response.abiMajor !=
        LMS_ABI_MAJOR
    )
    {
        result.error =
            Luma::ErrorCode::
                AbiMismatch;

        result.message =
            "LMS ABI mismatch";

        return result;
    }


    if (
        response.payloadLength >
        LMS_PAYLOAD_MAX
    )
    {
        result.error =
            Luma::ErrorCode::
                ProtocolError;

        result.message =
            "invalid LMS response";

        return result;
    }


    result.value =
        std::string(
            response.payload,
            response.payload
                + response.payloadLength
        );


    if (
        response.status != 0
    )
    {
        result.error =
            mapStatus(
                response.status
            );

        result.message =
            result.value;
    }


    return result;
}


/* ============================================================
 * App parser
 * ============================================================ */

Luma::Result<Luma::AppInfo>
parseApp(
    const std::string &line
)
{
    Luma::Result<Luma::AppInfo>
        result;


    std::vector<std::string>
        fields =
            split(
                line,
                '\t'
            );


    if (fields.size() < 3)
    {
        result.error =
            Luma::ErrorCode::
                ProtocolError;

        result.message =
            "invalid LMS app entry";

        return result;
    }


    result.value.id =
        fields[0];

    result.value.name =
        fields[1];

    result.value.version =
        fields[2];


    if (
        fields.size() >= 4 &&
        !fields[3].empty()
    )
    {
        result.value.permissions =
            split(
                fields[3],
                ','
            );
    }


    return result;
}


}


/* ============================================================
 * Luma::System
 * ============================================================ */

namespace Luma::System {


Result<std::string>
ping()
{
    return
        frameworkRequest(
            FW_CMD_PING
        );
}


Result<std::string>
frameworkVersion()
{
    return
        frameworkRequest(
            FW_CMD_VERSION
        );
}


Result<std::string>
capabilities()
{
    return
        frameworkRequest(
            FW_CMD_CAPABILITIES
        );
}


Result<std::string>
info()
{
    return
        frameworkRequest(
            FW_CMD_INFO
        );
}


Result<std::string>
uptime()
{
    return
        frameworkRequest(
            FW_CMD_UPTIME
        );
}


Result<std::string>
memory()
{
    return
        frameworkRequest(
            FW_CMD_MEMORY
        );
}


}


/* ============================================================
 * Luma::Power
 * ============================================================ */

namespace Luma::Power {


Result<void>
shutdown()
{
    Result<void> output;

    auto result =
        frameworkRequest(
            FW_CMD_SHUTDOWN
        );


    output.error =
        result.error;

    output.message =
        result.message;


    return output;
}


Result<void>
reboot()
{
    Result<void> output;

    auto result =
        frameworkRequest(
            FW_CMD_REBOOT
        );


    output.error =
        result.error;

    output.message =
        result.message;


    return output;
}


}


/* ============================================================
 * Luma::Services
 * ============================================================ */

namespace Luma::Services {


Result<std::string>
ping()
{
    return
        lmsRequest(
            LMS_CMD_PING
        );
}


Result<std::string>
version()
{
    return
        lmsRequest(
            LMS_CMD_VERSION
        );
}


Result<std::string>
capabilities()
{
    return
        lmsRequest(
            LMS_CMD_CAPABILITIES
        );
}


Result<std::string>
health()
{
    return
        lmsRequest(
            LMS_CMD_HEALTH
        );
}


Result<std::string>
deviceInfo()
{
    return
        lmsRequest(
            LMS_CMD_DEVICE_INFO
        );
}


Result<std::string>
session()
{
    return
        lmsRequest(
            LMS_CMD_SESSION
        );
}


}


/* ============================================================
 * Luma::Applications
 * ============================================================ */

namespace Luma::Applications {


Result<std::vector<AppInfo>>
list()
{
    Result<std::vector<AppInfo>>
        output;


    auto response =
        lmsRequest(
            LMS_CMD_APP_LIST
        );


    if (!response)
    {
        output.error =
            response.error;

        output.message =
            response.message;

        return output;
    }


    std::stringstream stream(
        response.value
    );

    std::string line;


    while (
        std::getline(
            stream,
            line
        )
    )
    {
        if (line.empty())
            continue;


        auto app =
            parseApp(
                line
            );


        if (!app)
            continue;


        output.value.push_back(
            app.value
        );
    }


    return output;
}


Result<AppInfo>
get(
    const std::string &appId
)
{
    auto response =
        lmsRequest(
            LMS_CMD_APP_GET,
            appId
        );


    if (!response)
    {
        Result<AppInfo>
            output;

        output.error =
            response.error;

        output.message =
            response.message;

        return output;
    }


    return
        parseApp(
            response.value
        );
}


Result<void>
registerApp(
    const AppInfo &app
)
{
    Result<void>
        output;


    std::string payload =
        app.id
        + "\t"
        + app.name
        + "\t"
        + app.version
        + "\t"
        + join(
            app.permissions,
            ','
        );


    auto response =
        lmsRequest(
            LMS_CMD_APP_REGISTER,
            payload
        );


    output.error =
        response.error;

    output.message =
        response.message;


    return output;
}


}


/* ============================================================
 * Luma::Permissions
 * ============================================================ */

namespace Luma::Permissions {


Result<bool>
check(
    const std::string &appId,
    const std::string &permission
)
{
    Result<bool>
        output;


    auto response =
        lmsRequest(
            LMS_CMD_PERMISSION_CHECK,
            appId
            + "\t"
            + permission
        );


    if (!response)
    {
        output.error =
            response.error;

        output.message =
            response.message;

        return output;
    }


    output.value =
        response.value ==
        "granted";


    return output;
}


}


/* ============================================================
 * Luma::Notifications
 * ============================================================ */

namespace Luma::Notifications {


Result<void>
post(
    const std::string &appId,
    const std::string &title,
    const std::string &body
)
{
    Result<void>
        output;


    auto response =
        lmsRequest(
            LMS_CMD_NOTIFY_POST,
            appId
            + "\t"
            + title
            + "\t"
            + body
        );


    output.error =
        response.error;

    output.message =
        response.message;


    return output;
}


Result<std::vector<Notification>>
list()
{
    Result<std::vector<Notification>>
        output;


    auto response =
        lmsRequest(
            LMS_CMD_NOTIFY_LIST
        );


    if (!response)
    {
        output.error =
            response.error;

        output.message =
            response.message;

        return output;
    }


    std::stringstream stream(
        response.value
    );

    std::string line;


    while (
        std::getline(
            stream,
            line
        )
    )
    {
        if (line.empty())
            continue;


        auto fields =
            split(
                line,
                '\t'
            );


        if (fields.size() < 4)
            continue;


        Notification item;


        try
        {
            item.id =
                std::stoull(
                    fields[0]
                );
        }
        catch (...)
        {
            continue;
        }


        item.appId =
            fields[1];

        item.title =
            fields[2];

        item.body =
            fields[3];


        output.value.push_back(
            item
        );
    }


    return output;
}


}


/* ============================================================
 * Luma::Application
 * ============================================================ */

namespace Luma {


Application::Application(
    std::string id,
    std::string name,
    std::string version,
    std::vector<std::string> permissions
)
    :
    m_id(
        std::move(id)
    ),
    m_name(
        std::move(name)
    ),
    m_version(
        std::move(version)
    ),
    m_permissions(
        std::move(permissions)
    )
{
}


const std::string &
Application::id() const
{
    return m_id;
}


const std::string &
Application::name() const
{
    return m_name;
}


const std::string &
Application::version() const
{
    return m_version;
}


const std::vector<std::string> &
Application::declaredPermissions() const
{
    return m_permissions;
}


Result<bool>
Application::isRegistered() const
{
    Result<bool>
        output;


    auto result =
        Applications::get(
            m_id
        );


    if (
        result.error ==
        ErrorCode::NotFound
    )
    {
        output.value =
            false;

        return output;
    }


    if (!result)
    {
        output.error =
            result.error;

        output.message =
            result.message;

        return output;
    }


    output.value =
        true;

    return output;
}


Result<void>
Application::registerWithLMS() const
{
    AppInfo info;

    info.id =
        m_id;

    info.name =
        m_name;

    info.version =
        m_version;

    info.permissions =
        m_permissions;


    return
        Applications::registerApp(
            info
        );
}


Result<bool>
Application::hasPermission(
    const std::string &permission
) const
{
    return
        Permissions::check(
            m_id,
            permission
        );
}


Result<void>
Application::notify(
    const std::string &title,
    const std::string &body
) const
{
    return
        Notifications::post(
            m_id,
            title,
            body
        );
}


}
