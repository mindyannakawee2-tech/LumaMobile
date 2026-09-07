#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <sys/socket.h>
#include <sys/un.h>

#include "luma_protocol.h"


static uint32_t next_request_id = 1;


static const char *status_name(
    int status
)
{
    switch (
        status
    ) {

        case LUMA_OK:
            return "OK";

        case LUMA_ERR_BAD_MAGIC:
            return "BAD_MAGIC";

        case LUMA_ERR_BAD_ABI:
            return "BAD_ABI";

        case LUMA_ERR_BAD_MESSAGE:
            return "BAD_MESSAGE";

        case LUMA_ERR_UNKNOWN_COMMAND:
            return "UNKNOWN_COMMAND";

        case LUMA_ERR_PERMISSION:
            return "PERMISSION_DENIED";

        case LUMA_ERR_INTERNAL:
            return "INTERNAL_ERROR";

        default:
            return "UNKNOWN_ERROR";
    }
}


static void usage(void)
{
    printf(
        "Luma Framework Control\n"
        "\n"
        "CoreService:\n"
        "  lumactl ping\n"
        "  lumactl version\n"
        "  lumactl capabilities\n"
        "\n"
        "SystemService:\n"
        "  lumactl system info\n"
        "  lumactl system uptime\n"
        "  lumactl system memory\n"
        "\n"
        "PowerService:\n"
        "  lumactl power shutdown\n"
        "  lumactl power reboot\n"
    );
}


static int resolve_command(
    int argc,
    char **argv,
    uint16_t *command
)
{
    if (
        argc == 2 &&
        strcmp(argv[1], "ping") == 0
    ) {

        *command =
            LUMA_CORE_PING;

        return 0;
    }


    if (
        argc == 2 &&
        strcmp(argv[1], "version") == 0
    ) {

        *command =
            LUMA_CORE_VERSION;

        return 0;
    }


    if (
        argc == 2 &&
        strcmp(argv[1], "capabilities") == 0
    ) {

        *command =
            LUMA_CORE_CAPABILITIES;

        return 0;
    }


    if (
        argc == 3 &&
        strcmp(argv[1], "system") == 0
    ) {

        if (
            strcmp(
                argv[2],
                "info"
            ) == 0
        ) {

            *command =
                LUMA_SYSTEM_INFO;

            return 0;
        }


        if (
            strcmp(
                argv[2],
                "uptime"
            ) == 0
        ) {

            *command =
                LUMA_SYSTEM_UPTIME;

            return 0;
        }


        if (
            strcmp(
                argv[2],
                "memory"
            ) == 0
        ) {

            *command =
                LUMA_SYSTEM_MEMORY;

            return 0;
        }
    }


    if (
        argc == 3 &&
        strcmp(argv[1], "power") == 0
    ) {

        if (
            strcmp(
                argv[2],
                "shutdown"
            ) == 0
        ) {

            *command =
                LUMA_POWER_SHUTDOWN;

            return 0;
        }


        if (
            strcmp(
                argv[2],
                "reboot"
            ) == 0
        ) {

            *command =
                LUMA_POWER_REBOOT;

            return 0;
        }
    }


    return -1;
}


int main(
    int argc,
    char **argv
)
{
    uint16_t command;


    if (
        resolve_command(
            argc,
            argv,
            &command
        ) != 0
    ) {

        usage();

        return 1;
    }


    int sock =
        socket(
            AF_UNIX,
            SOCK_SEQPACKET,
            0
        );


    if (
        sock < 0
    ) {

        perror(
            "lumactl: socket"
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
        connect(
            sock,
            (struct sockaddr *)&address,
            sizeof(address)
        ) != 0
    ) {

        perror(
            "lumactl: framework unavailable"
        );

        close(
            sock
        );

        return 1;
    }


    struct luma_message request;

    memset(
        &request,
        0,
        sizeof(request)
    );


    request.magic =
        LUMA_MAGIC;

    request.abi_major =
        LUMA_ABI_MAJOR;

    request.abi_minor =
        LUMA_ABI_MINOR;

    request.type =
        LUMA_MSG_REQUEST;

    request.command =
        command;

    request.request_id =
        next_request_id++;


    if (
        send(
            sock,
            &request,
            sizeof(request),
            0
        ) < 0
    ) {

        perror(
            "lumactl: send"
        );

        close(
            sock
        );

        return 1;
    }


    struct luma_message response;

    memset(
        &response,
        0,
        sizeof(response)
    );


    ssize_t bytes =
        recv(
            sock,
            &response,
            sizeof(response),
            0
        );


    close(
        sock
    );


    if (
        bytes <= 0
    ) {

        fprintf(
            stderr,
            "Framework returned no response\n"
        );

        return 1;
    }


    if (
        response.magic !=
        LUMA_MAGIC
    ) {

        fprintf(
            stderr,
            "Invalid framework response\n"
        );

        return 1;
    }


    if (
        response.request_id !=
        request.request_id
    ) {

        fprintf(
            stderr,
            "Request ID mismatch\n"
        );

        return 1;
    }


    if (
        response.status !=
        LUMA_OK
    ) {

        fprintf(
            stderr,
            "Luma Framework error: %s (%d)\n",
            status_name(
                response.status
            ),
            response.status
        );


        if (
            response.payload_length
        )
            fprintf(
                stderr,
                "%s\n",
                response.payload
            );


        return 1;
    }


    if (
        response.payload_length
    ) {

        fwrite(
            response.payload,
            1,
            response.payload_length,
            stdout
        );


        if (
            response.payload[
                response.payload_length - 1
            ] != '\n'
        )
            putchar('\n');
    }


    return 0;
}
