#include "../include/lms_protocol.h"

#include <sys/socket.h>
#include <sys/un.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>


static uint32_t request_counter = 1;


static int request(
    uint16_t command,
    const char *payload
)
{
    int fd =
        socket(
            AF_UNIX,
            SOCK_SEQPACKET,
            0
        );


    if (fd < 0) {

        perror("socket");

        return 1;
    }


    struct sockaddr_un addr;

    memset(
        &addr,
        0,
        sizeof(addr)
    );


    addr.sun_family =
        AF_UNIX;


    strncpy(
        addr.sun_path,
        LMS_SOCKET_PATH,
        sizeof(addr.sun_path) - 1
    );


    if (
        connect(
            fd,
            (struct sockaddr *)&addr,
            sizeof(addr)
        ) != 0
    ) {

        perror("connect");

        close(fd);

        return 1;
    }


    struct lms_message req;

    memset(
        &req,
        0,
        sizeof(req)
    );


    req.magic =
        LMS_MAGIC;

    req.abi_major =
        LMS_ABI_MAJOR;

    req.abi_minor =
        LMS_ABI_MINOR;

    req.type =
        LMS_MSG_REQUEST;

    req.command =
        command;

    req.request_id =
        request_counter++;


    if (payload) {

        size_t len =
            strlen(payload);


        if (
            len >=
            LMS_MAX_PAYLOAD
        ) {

            fprintf(
                stderr,
                "payload too large\n"
            );

            close(fd);

            return 1;
        }


        memcpy(
            req.payload,
            payload,
            len
        );


        req.payload_length =
            (uint32_t)len;
    }


    if (
        send(
            fd,
            &req,
            sizeof(req),
            0
        ) !=
        (ssize_t)sizeof(req)
    ) {

        perror("send");

        close(fd);

        return 1;
    }


    struct lms_message res;

    memset(
        &res,
        0,
        sizeof(res)
    );


    ssize_t got =
        recv(
            fd,
            &res,
            sizeof(res),
            0
        );


    close(fd);


    if (
        got <= 0
    ) {

        fprintf(
            stderr,
            "no response\n"
        );

        return 1;
    }


    if (
        res.payload_length >
        LMS_MAX_PAYLOAD
    ) {

        fprintf(
            stderr,
            "invalid response\n"
        );

        return 1;
    }


    res.payload[
        res.payload_length
    ] = '\0';


    if (
        res.status !=
        LMS_OK
    ) {

        fprintf(
            stderr,
            "LMS error %d: %s\n",
            res.status,
            res.payload
        );

        return 1;
    }


    if (
        res.payload_length
    ) {

        printf(
            "%s\n",
            res.payload
        );
    }


    return 0;
}


static void usage(
    const char *program
)
{
    fprintf(
        stderr,

        "LMS 0.2 CLI\n\n"

        "Usage:\n"

        "  %s ping\n"
        "  %s version\n"
        "  %s capabilities\n"
        "  %s health\n"

        "  %s device info\n"
        "  %s device session\n"

        "  %s app list\n"
        "  %s app get APP_ID\n"

        "  %s app register APP_ID NAME VERSION PERMISSIONS\n"

        "  %s permission check APP_ID PERMISSION\n"

        "  %s notify list\n"
        "  %s notify clear\n"

        "  %s notify post APP_ID TITLE BODY\n",

        program,
        program,
        program,
        program,

        program,
        program,

        program,
        program,

        program,

        program,

        program,
        program,

        program
    );
}


int main(
    int argc,
    char **argv
)
{
    if (
        argc < 2
    ) {

        usage(argv[0]);

        return 1;
    }


    if (
        strcmp(
            argv[1],
            "ping"
        ) == 0
    ) {

        return request(
            LMS_CMD_CORE_PING,
            ""
        );
    }


    if (
        strcmp(
            argv[1],
            "version"
        ) == 0
    ) {

        return request(
            LMS_CMD_CORE_VERSION,
            ""
        );
    }


    if (
        strcmp(
            argv[1],
            "capabilities"
        ) == 0
    ) {

        return request(
            LMS_CMD_CORE_CAPABILITIES,
            ""
        );
    }


    if (
        strcmp(
            argv[1],
            "health"
        ) == 0
    ) {

        return request(
            LMS_CMD_CORE_HEALTH,
            ""
        );
    }


    if (
        argc >= 3 &&
        strcmp(
            argv[1],
            "device"
        ) == 0
    ) {

        if (
            strcmp(
                argv[2],
                "info"
            ) == 0
        ) {

            return request(
                LMS_CMD_DEVICE_INFO,
                ""
            );
        }


        if (
            strcmp(
                argv[2],
                "session"
            ) == 0
        ) {

            return request(
                LMS_CMD_DEVICE_SESSION,
                ""
            );
        }
    }


    if (
        argc >= 3 &&
        strcmp(
            argv[1],
            "app"
        ) == 0
    ) {

        if (
            strcmp(
                argv[2],
                "list"
            ) == 0
        ) {

            return request(
                LMS_CMD_APP_LIST,
                ""
            );
        }


        if (
            argc >= 4 &&
            strcmp(
                argv[2],
                "get"
            ) == 0
        ) {

            return request(
                LMS_CMD_APP_GET,
                argv[3]
            );
        }


        if (
            argc >= 7 &&
            strcmp(
                argv[2],
                "register"
            ) == 0
        ) {

            char payload[
                LMS_MAX_PAYLOAD
            ];


            snprintf(
                payload,
                sizeof(payload),
                "%s\t%s\t%s\t%s",
                argv[3],
                argv[4],
                argv[5],
                argv[6]
            );


            return request(
                LMS_CMD_APP_REGISTER,
                payload
            );
        }
    }


    if (
        argc >= 5 &&
        strcmp(
            argv[1],
            "permission"
        ) == 0 &&
        strcmp(
            argv[2],
            "check"
        ) == 0
    ) {

        char payload[
            LMS_MAX_PAYLOAD
        ];


        snprintf(
            payload,
            sizeof(payload),
            "%s\t%s",
            argv[3],
            argv[4]
        );


        return request(
            LMS_CMD_PERMISSION_CHECK,
            payload
        );
    }


    if (
        argc >= 3 &&
        strcmp(
            argv[1],
            "notify"
        ) == 0
    ) {

        if (
            strcmp(
                argv[2],
                "list"
            ) == 0
        ) {

            return request(
                LMS_CMD_NOTIFY_LIST,
                ""
            );
        }


        if (
            strcmp(
                argv[2],
                "clear"
            ) == 0
        ) {

            return request(
                LMS_CMD_NOTIFY_CLEAR,
                ""
            );
        }


        if (
            argc >= 6 &&
            strcmp(
                argv[2],
                "post"
            ) == 0
        ) {

            char payload[
                LMS_MAX_PAYLOAD
            ];


            snprintf(
                payload,
                sizeof(payload),
                "%s\t%s\t%s",
                argv[3],
                argv[4],
                argv[5]
            );


            return request(
                LMS_CMD_NOTIFY_POST,
                payload
            );
        }
    }


    usage(argv[0]);

    return 1;
}
