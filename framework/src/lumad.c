#define _GNU_SOURCE

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>
#include <errno.h>
#include <fcntl.h>

#include <sys/socket.h>
#include <sys/un.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/sysinfo.h>
#include <sys/utsname.h>
#include <sys/reboot.h>

#include <linux/reboot.h>

#include "luma_protocol.h"


static volatile sig_atomic_t running = 1;


static void signal_handler(int sig)
{
    (void)sig;
    running = 0;
}


static void log_line(const char *message)
{
    fprintf(
        stderr,
        "[lumad] %s\n",
        message
    );
}


static void prepare_response(
    struct luma_message *response,
    const struct luma_message *request
)
{
    memset(
        response,
        0,
        sizeof(*response)
    );

    response->magic = LUMA_MAGIC;

    response->abi_major = LUMA_ABI_MAJOR;
    response->abi_minor = LUMA_ABI_MINOR;

    response->type = LUMA_MSG_RESPONSE;

    response->command =
        request->command;

    response->request_id =
        request->request_id;

    response->status =
        LUMA_OK;
}


static void response_text(
    struct luma_message *response,
    const char *text
)
{
    size_t length =
        strlen(text);

    if (length >= LUMA_MAX_PAYLOAD)
        length =
            LUMA_MAX_PAYLOAD - 1;

    memcpy(
        response->payload,
        text,
        length
    );

    response->payload[length] = '\0';

    response->payload_length =
        (uint32_t)length;
}


static int request_valid(
    const struct luma_message *request
)
{
    if (
        request->magic !=
        LUMA_MAGIC
    )
        return LUMA_ERR_BAD_MAGIC;


    if (
        request->abi_major !=
        LUMA_ABI_MAJOR
    )
        return LUMA_ERR_BAD_ABI;


    if (
        request->type !=
        LUMA_MSG_REQUEST
    )
        return LUMA_ERR_BAD_MESSAGE;


    if (
        request->payload_length >
        LUMA_MAX_PAYLOAD
    )
        return LUMA_ERR_BAD_MESSAGE;


    return LUMA_OK;
}


static void system_info(
    struct luma_message *response
)
{
    struct utsname u;

    if (
        uname(&u) != 0
    ) {

        response->status =
            LUMA_ERR_INTERNAL;

        response_text(
            response,
            "uname failed"
        );

        return;
    }


    char buffer[1024];

    snprintf(
        buffer,
        sizeof(buffer),

        "os=LumaMobile\n"
        "framework=%s\n"
        "kernel=%s\n"
        "machine=%s\n",

        LUMA_FRAMEWORK_VERSION,
        u.release,
        u.machine
    );


    response_text(
        response,
        buffer
    );
}


static void system_uptime(
    struct luma_message *response
)
{
    struct sysinfo info;


    if (
        sysinfo(&info) != 0
    ) {

        response->status =
            LUMA_ERR_INTERNAL;

        return;
    }


    char buffer[128];


    snprintf(
        buffer,
        sizeof(buffer),
        "%ld",
        info.uptime
    );


    response_text(
        response,
        buffer
    );
}


static void system_memory(
    struct luma_message *response
)
{
    struct sysinfo info;


    if (
        sysinfo(&info) != 0
    ) {

        response->status =
            LUMA_ERR_INTERNAL;

        return;
    }


    unsigned long long unit =
        info.mem_unit;


    unsigned long long total =
        (
            (unsigned long long)
            info.totalram *
            unit
        ) /
        1024 /
        1024;


    unsigned long long free =
        (
            (unsigned long long)
            info.freeram *
            unit
        ) /
        1024 /
        1024;


    char buffer[256];


    snprintf(
        buffer,
        sizeof(buffer),

        "total_mb=%llu\n"
        "free_mb=%llu\n"
        "used_mb=%llu\n",

        total,
        free,
        total - free
    );


    response_text(
        response,
        buffer
    );
}


static int client_is_privileged(
    int client
)
{
    struct ucred credentials;

    socklen_t length =
        sizeof(credentials);


    if (
        getsockopt(
            client,
            SOL_SOCKET,
            SO_PEERCRED,
            &credentials,
            &length
        ) != 0
    )
        return 0;


    /*
     * For Framework 2.0:
     *
     * destructive system operations require root.
     *
     * Later this becomes Luma Permissions.
     */

    return credentials.uid == 0;
}


static void handle_request(
    int client,
    const struct luma_message *request,
    struct luma_message *response
)
{
    prepare_response(
        response,
        request
    );


    int valid =
        request_valid(
            request
        );


    if (
        valid != LUMA_OK
    ) {

        response->status =
            valid;

        response_text(
            response,
            "invalid request"
        );

        return;
    }


    switch (
        request->command
    ) {

        /* ====================================================
         * CoreService
         * ==================================================== */

        case LUMA_CORE_PING:

            response_text(
                response,
                "PONG"
            );

            break;


        case LUMA_CORE_VERSION:

            response_text(
                response,
                LUMA_FRAMEWORK_VERSION
            );

            break;


        case LUMA_CORE_CAPABILITIES:

            response_text(
                response,

                "core\n"
                "system\n"
                "power\n"
            );

            break;


        /* ====================================================
         * SystemService
         * ==================================================== */

        case LUMA_SYSTEM_INFO:

            system_info(
                response
            );

            break;


        case LUMA_SYSTEM_UPTIME:

            system_uptime(
                response
            );

            break;


        case LUMA_SYSTEM_MEMORY:

            system_memory(
                response
            );

            break;


        /* ====================================================
         * PowerService
         * ==================================================== */

        case LUMA_POWER_SHUTDOWN:

            if (
                !client_is_privileged(
                    client
                )
            ) {

                response->status =
                    LUMA_ERR_PERMISSION;

                response_text(
                    response,
                    "permission denied"
                );

                break;
            }


            response_text(
                response,
                "shutdown accepted"
            );

            send(
                client,
                response,
                sizeof(*response),
                MSG_NOSIGNAL
            );

            sync();

            reboot(
                LINUX_REBOOT_CMD_POWER_OFF
            );

            break;


        case LUMA_POWER_REBOOT:

            if (
                !client_is_privileged(
                    client
                )
            ) {

                response->status =
                    LUMA_ERR_PERMISSION;

                response_text(
                    response,
                    "permission denied"
                );

                break;
            }


            response_text(
                response,
                "reboot accepted"
            );

            send(
                client,
                response,
                sizeof(*response),
                MSG_NOSIGNAL
            );

            sync();

            reboot(
                LINUX_REBOOT_CMD_RESTART
            );

            break;


        default:

            response->status =
                LUMA_ERR_UNKNOWN_COMMAND;

            response_text(
                response,
                "unknown command"
            );

            break;
    }
}


int main(void)
{
    signal(
        SIGINT,
        signal_handler
    );

    signal(
        SIGTERM,
        signal_handler
    );


    mkdir(
        "/run",
        0755
    );

    mkdir(
        "/run/luma",
        0755
    );


    unlink(
        LUMA_SOCKET_PATH
    );

    unlink(
        LUMA_READY_PATH
    );


    int server =
        socket(
            AF_UNIX,
            SOCK_SEQPACKET,
            0
        );


    if (
        server < 0
    ) {

        perror(
            "lumad: socket"
        );

        return 1;
    }


    struct sockaddr_un address;

    memset(
        &address,
        0,
        sizeof(address)
    );


    address.sun_family =
        AF_UNIX;


    strncpy(
        address.sun_path,
        LUMA_SOCKET_PATH,
        sizeof(address.sun_path) - 1
    );


    if (
        bind(
            server,
            (struct sockaddr *)&address,
            sizeof(address)
        ) != 0
    ) {

        perror(
            "lumad: bind"
        );

        close(server);

        return 1;
    }


    /*
     * Don't expose framework control as 0666.
     *
     * Root-only for now.
     * Later we'll introduce Luma application identities
     * and permissions.
     */

    chmod(
        LUMA_SOCKET_PATH,
        0600
    );


    if (
        listen(
            server,
            32
        ) != 0
    ) {

        perror(
            "lumad: listen"
        );

        close(server);

        return 1;
    }


    int ready =
        open(
            LUMA_READY_PATH,
            O_CREAT |
            O_WRONLY |
            O_TRUNC,
            0644
        );


    if (
        ready >= 0
    ) {

        ssize_t written = write(
            ready,
            "ready\\n",
            6
        );

        if (written != 6) {
            fprintf(
                stderr,
                "[lumad] warning: failed to write ready file\\n"
            );
        }

        close(
            ready
        );
    }


    fprintf(
        stderr,
        "[lumad] Luma Framework %s\n",
        LUMA_FRAMEWORK_VERSION
    );

    fprintf(
        stderr,
        "[lumad] ABI %u.%u\n",
        LUMA_ABI_MAJOR,
        LUMA_ABI_MINOR
    );

    fprintf(
        stderr,
        "[lumad] IPC %s\n",
        LUMA_SOCKET_PATH
    );


    while (
        running
    ) {

        int client =
            accept(
                server,
                NULL,
                NULL
            );


        if (
            client < 0
        ) {

            if (
                errno == EINTR
            )
                continue;


            perror(
                "lumad: accept"
            );

            break;
        }


        struct luma_message request;

        memset(
            &request,
            0,
            sizeof(request)
        );


        ssize_t bytes =
            recv(
                client,
                &request,
                sizeof(request),
                0
            );


        if (
            bytes > 0
        ) {

            struct luma_message response;


            handle_request(
                client,
                &request,
                &response
            );


            /*
             * Shutdown/reboot may already have sent
             * their response.
             */

            if (
                request.command !=
                    LUMA_POWER_SHUTDOWN &&
                request.command !=
                    LUMA_POWER_REBOOT
            ) {

                send(
                    client,
                    &response,
                    sizeof(response),
                    MSG_NOSIGNAL
                );
            }
        }


        close(
            client
        );
    }


    log_line(
        "stopping"
    );


    close(
        server
    );


    unlink(
        LUMA_SOCKET_PATH
    );

    unlink(
        LUMA_READY_PATH
    );


    return 0;
}
