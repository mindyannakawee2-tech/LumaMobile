#ifndef LUMA_PROTOCOL_H
#define LUMA_PROTOCOL_H

#include <stdint.h>


#define LUMA_FRAMEWORK_VERSION "2.0.0"

#define LUMA_SOCKET_PATH "/run/luma/framework.sock"
#define LUMA_READY_PATH  "/run/luma/framework.ready"

#define LUMA_MAGIC 0x4C554D41u   /* LUMA */

#define LUMA_ABI_MAJOR 2
#define LUMA_ABI_MINOR 0

#define LUMA_MAX_PAYLOAD 2048


enum luma_message_type {
    LUMA_MSG_REQUEST  = 1,
    LUMA_MSG_RESPONSE = 2,
    LUMA_MSG_EVENT    = 3
};


enum luma_status {
    LUMA_OK                  = 0,

    LUMA_ERR_BAD_MAGIC       = -1,
    LUMA_ERR_BAD_ABI         = -2,
    LUMA_ERR_BAD_MESSAGE     = -3,
    LUMA_ERR_UNKNOWN_COMMAND = -4,
    LUMA_ERR_PERMISSION      = -5,
    LUMA_ERR_INTERNAL        = -6
};


/*
 * Services
 */

enum luma_command {

    /* CoreService */
    LUMA_CORE_PING          = 0x0001,
    LUMA_CORE_VERSION       = 0x0002,
    LUMA_CORE_CAPABILITIES  = 0x0003,

    /* SystemService */
    LUMA_SYSTEM_INFO        = 0x0101,
    LUMA_SYSTEM_UPTIME      = 0x0102,
    LUMA_SYSTEM_MEMORY      = 0x0103,

    /* PowerService */
    LUMA_POWER_SHUTDOWN     = 0x0201,
    LUMA_POWER_REBOOT       = 0x0202
};


struct luma_message {

    uint32_t magic;

    uint16_t abi_major;
    uint16_t abi_minor;

    uint16_t type;
    uint16_t command;

    uint32_t request_id;

    int32_t status;

    uint32_t payload_length;

    char payload[LUMA_MAX_PAYLOAD];
};


#endif
