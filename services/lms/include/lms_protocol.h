#ifndef LMS_PROTOCOL_H
#define LMS_PROTOCOL_H

#include <stdint.h>

#define LMS_VERSION "0.2.0"

#define LMS_SOCKET_PATH "/run/lms/lms.sock"
#define LMS_READY_PATH  "/run/lms/lms.ready"

#define LMS_APP_DB_PATH \
    "/var/lib/lms/apps.tsv"

#define LMS_NOTIFICATION_DB_PATH \
    "/var/lib/lms/notifications.tsv"

#define LMS_MAGIC 0x4C4D5353u

#define LMS_ABI_MAJOR 2
#define LMS_ABI_MINOR 0

#define LMS_MAX_PAYLOAD 4096


enum lms_message_type {
    LMS_MSG_REQUEST  = 1,
    LMS_MSG_RESPONSE = 2,
    LMS_MSG_EVENT    = 3
};


enum lms_status {
    LMS_OK = 0,

    LMS_ERR_BAD_MAGIC       = -1,
    LMS_ERR_BAD_ABI         = -2,
    LMS_ERR_BAD_MESSAGE     = -3,
    LMS_ERR_INTERNAL        = -4,
    LMS_ERR_UNKNOWN_COMMAND = -5,
    LMS_ERR_PERMISSION      = -6,
    LMS_ERR_NOT_FOUND       = -7,
    LMS_ERR_INVALID         = -8,
    LMS_ERR_UNAVAILABLE     = -9
};


enum lms_command {

    /* Core */
    LMS_CMD_CORE_PING         = 0x0001,
    LMS_CMD_CORE_VERSION      = 0x0002,
    LMS_CMD_CORE_CAPABILITIES = 0x0003,
    LMS_CMD_CORE_HEALTH       = 0x0004,

    /* Device */
    LMS_CMD_DEVICE_INFO       = 0x0101,
    LMS_CMD_DEVICE_SESSION    = 0x0102,

    /* Applications */
    LMS_CMD_APP_REGISTER      = 0x0201,
    LMS_CMD_APP_LIST          = 0x0202,
    LMS_CMD_APP_GET           = 0x0203,

    /* Permissions */
    LMS_CMD_PERMISSION_CHECK  = 0x0301,

    /* Notifications */
    LMS_CMD_NOTIFY_POST       = 0x0401,
    LMS_CMD_NOTIFY_LIST       = 0x0402,
    LMS_CMD_NOTIFY_CLEAR      = 0x0403
};


struct lms_message {

    uint32_t magic;

    uint16_t abi_major;
    uint16_t abi_minor;

    uint16_t type;
    uint16_t command;

    uint32_t request_id;

    int32_t status;

    uint32_t payload_length;

    char payload[LMS_MAX_PAYLOAD];
};


#endif
