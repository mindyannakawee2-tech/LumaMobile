#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <ctype.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <signal.h>

#include <sys/ioctl.h>
#include <sys/mman.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <sys/stat.h>

#include <linux/fb.h>

#include "luma_protocol.h"


static struct fb_var_screeninfo vinfo;
static struct fb_fix_screeninfo finfo;

static uint8_t *fb = NULL;
static size_t fb_size = 0;
static int fb_fd = -1;

static volatile sig_atomic_t running = 1;


/* ------------------------------------------------------------
 * Basic colors
 * ------------------------------------------------------------ */

#define RGB(r,g,b) \
    (((uint32_t)(r) << 16) | ((uint32_t)(g) << 8) | (uint32_t)(b))

#define COLOR_BG       RGB(242, 243, 247)
#define COLOR_CARD     RGB(255, 255, 255)
#define COLOR_TEXT     RGB(24, 24, 28)
#define COLOR_MUTED    RGB(108, 108, 116)
#define COLOR_ACCENT   RGB(88, 86, 214)
#define COLOR_DARK     RGB(31, 31, 36)
#define COLOR_GREEN    RGB(52, 199, 89)
#define COLOR_BLUE     RGB(10, 132, 255)
#define COLOR_ORANGE   RGB(255, 149, 0)
#define COLOR_RED      RGB(255, 69, 58)


static void signal_handler(int sig)
{
    (void)sig;
    running = 0;
}


/* ------------------------------------------------------------
 * Framebuffer pixel packing
 * ------------------------------------------------------------ */

static uint32_t scale_component(
    uint8_t value,
    uint32_t length
)
{
    if (length == 0)
        return 0;

    uint32_t max = (1u << length) - 1u;

    return ((uint32_t)value * max) / 255u;
}


static uint32_t framebuffer_color(uint32_t rgb)
{
    uint8_t r = (rgb >> 16) & 0xff;
    uint8_t g = (rgb >> 8) & 0xff;
    uint8_t b = rgb & 0xff;

    uint32_t out = 0;

    out |= scale_component(r, vinfo.red.length)
        << vinfo.red.offset;

    out |= scale_component(g, vinfo.green.length)
        << vinfo.green.offset;

    out |= scale_component(b, vinfo.blue.length)
        << vinfo.blue.offset;

    return out;
}


static void pixel(int x, int y, uint32_t color)
{
    if (
        x < 0 ||
        y < 0 ||
        x >= (int)vinfo.xres ||
        y >= (int)vinfo.yres
    )
        return;

    long location =
        (x + vinfo.xoffset) *
            (vinfo.bits_per_pixel / 8) +
        (y + vinfo.yoffset) *
            finfo.line_length;

    uint32_t c = framebuffer_color(color);

    if (vinfo.bits_per_pixel == 32) {

        *((uint32_t *)(fb + location)) = c;

    } else if (vinfo.bits_per_pixel == 16) {

        *((uint16_t *)(fb + location)) =
            (uint16_t)c;
    }
}


/* ------------------------------------------------------------
 * Primitives
 * ------------------------------------------------------------ */

static void rect(
    int x,
    int y,
    int w,
    int h,
    uint32_t color
)
{
    for (int yy = y; yy < y + h; yy++)
        for (int xx = x; xx < x + w; xx++)
            pixel(xx, yy, color);
}


static void circle(
    int cx,
    int cy,
    int radius,
    uint32_t color
)
{
    int r2 = radius * radius;

    for (int y = -radius; y <= radius; y++) {

        for (int x = -radius; x <= radius; x++) {

            if ((x * x + y * y) <= r2)
                pixel(cx + x, cy + y, color);
        }
    }
}


static void rounded_rect(
    int x,
    int y,
    int w,
    int h,
    int radius,
    uint32_t color
)
{
    rect(
        x + radius,
        y,
        w - radius * 2,
        h,
        color
    );

    rect(
        x,
        y + radius,
        w,
        h - radius * 2,
        color
    );

    circle(
        x + radius,
        y + radius,
        radius,
        color
    );

    circle(
        x + w - radius - 1,
        y + radius,
        radius,
        color
    );

    circle(
        x + radius,
        y + h - radius - 1,
        radius,
        color
    );

    circle(
        x + w - radius - 1,
        y + h - radius - 1,
        radius,
        color
    );
}


/* ------------------------------------------------------------
 * Tiny Luma bitmap font
 *
 * 5x7 glyphs.
 * Lowercase automatically becomes uppercase.
 * ------------------------------------------------------------ */

static const uint8_t *glyph(char c)
{
    static const uint8_t blank[7] =
        {0,0,0,0,0,0,0};

    static const uint8_t unknown[7] =
        {31,17,1,2,4,0,4};

    static const uint8_t A[7]={14,17,17,31,17,17,17};
    static const uint8_t B[7]={30,17,17,30,17,17,30};
    static const uint8_t C[7]={14,17,16,16,16,17,14};
    static const uint8_t D[7]={30,17,17,17,17,17,30};
    static const uint8_t E[7]={31,16,16,30,16,16,31};
    static const uint8_t F[7]={31,16,16,30,16,16,16};
    static const uint8_t G[7]={14,17,16,23,17,17,14};
    static const uint8_t H[7]={17,17,17,31,17,17,17};
    static const uint8_t I[7]={31,4,4,4,4,4,31};
    static const uint8_t J[7]={7,2,2,2,18,18,12};
    static const uint8_t K[7]={17,18,20,24,20,18,17};
    static const uint8_t L[7]={16,16,16,16,16,16,31};
    static const uint8_t M[7]={17,27,21,21,17,17,17};
    static const uint8_t N[7]={17,25,21,19,17,17,17};
    static const uint8_t O[7]={14,17,17,17,17,17,14};
    static const uint8_t P[7]={30,17,17,30,16,16,16};
    static const uint8_t Q[7]={14,17,17,17,21,18,13};
    static const uint8_t R[7]={30,17,17,30,20,18,17};
    static const uint8_t S[7]={15,16,16,14,1,1,30};
    static const uint8_t T[7]={31,4,4,4,4,4,4};
    static const uint8_t U[7]={17,17,17,17,17,17,14};
    static const uint8_t V[7]={17,17,17,17,17,10,4};
    static const uint8_t W[7]={17,17,17,21,21,21,10};
    static const uint8_t X[7]={17,17,10,4,10,17,17};
    static const uint8_t Y[7]={17,17,10,4,4,4,4};
    static const uint8_t Z[7]={31,1,2,4,8,16,31};

    static const uint8_t N0[7]={14,17,19,21,25,17,14};
    static const uint8_t N1[7]={4,12,4,4,4,4,14};
    static const uint8_t N2[7]={14,17,1,2,4,8,31};
    static const uint8_t N3[7]={30,1,1,14,1,1,30};
    static const uint8_t N4[7]={2,6,10,18,31,2,2};
    static const uint8_t N5[7]={31,16,16,30,1,1,30};
    static const uint8_t N6[7]={14,16,16,30,17,17,14};
    static const uint8_t N7[7]={31,1,2,4,8,8,8};
    static const uint8_t N8[7]={14,17,17,14,17,17,14};
    static const uint8_t N9[7]={14,17,17,15,1,1,14};

    static const uint8_t COLON[7]={0,4,4,0,4,4,0};
    static const uint8_t DOT[7]={0,0,0,0,0,4,4};
    static const uint8_t DASH[7]={0,0,0,31,0,0,0};
    static const uint8_t SLASH[7]={1,2,2,4,8,8,16};
    static const uint8_t PERCENT[7]={17,2,4,8,16,0,17};

    c = toupper((unsigned char)c);

    switch (c) {
        case ' ': return blank;

        case 'A': return A;
        case 'B': return B;
        case 'C': return C;
        case 'D': return D;
        case 'E': return E;
        case 'F': return F;
        case 'G': return G;
        case 'H': return H;
        case 'I': return I;
        case 'J': return J;
        case 'K': return K;
        case 'L': return L;
        case 'M': return M;
        case 'N': return N;
        case 'O': return O;
        case 'P': return P;
        case 'Q': return Q;
        case 'R': return R;
        case 'S': return S;
        case 'T': return T;
        case 'U': return U;
        case 'V': return V;
        case 'W': return W;
        case 'X': return X;
        case 'Y': return Y;
        case 'Z': return Z;

        case '0': return N0;
        case '1': return N1;
        case '2': return N2;
        case '3': return N3;
        case '4': return N4;
        case '5': return N5;
        case '6': return N6;
        case '7': return N7;
        case '8': return N8;
        case '9': return N9;

        case ':': return COLON;
        case '.': return DOT;
        case '-': return DASH;
        case '/': return SLASH;
        case '%': return PERCENT;

        default:
            return unknown;
    }
}


static void draw_char(
    int x,
    int y,
    char c,
    int scale,
    uint32_t color
)
{
    const uint8_t *g = glyph(c);

    for (int row = 0; row < 7; row++) {

        for (int col = 0; col < 5; col++) {

            if (
                g[row] &
                (1 << (4 - col))
            ) {

                rect(
                    x + col * scale,
                    y + row * scale,
                    scale,
                    scale,
                    color
                );
            }
        }
    }
}


static void text(
    int x,
    int y,
    const char *value,
    int scale,
    uint32_t color
)
{
    int cursor = x;

    while (*value) {

        draw_char(
            cursor,
            y,
            *value,
            scale,
            color
        );

        cursor += 6 * scale;

        value++;
    }
}


/* ------------------------------------------------------------
 * Luma Home demo UI
 * ------------------------------------------------------------ */

static void draw_home(void)
{
    int w = vinfo.xres;
    int h = vinfo.yres;

    rect(0, 0, w, h, COLOR_BG);


    /* top status */

    text(
        35,
        25,
        "LUMAMOBILE",
        3,
        COLOR_TEXT
    );

    text(
        w - 170,
        30,
        "100%",
        2,
        COLOR_TEXT
    );


    /* greeting */

    text(
        45,
        95,
        "WELCOME",
        5,
        COLOR_TEXT
    );


    /* card 1 */

    int margin = 45;
    int gap = 22;

    int card_w =
        (w - margin * 2 - gap) / 2;

    int card_h = 170;

    rounded_rect(
        margin,
        175,
        card_w,
        card_h,
        24,
        COLOR_CARD
    );

    circle(
        margin + 55,
        225,
        25,
        COLOR_ACCENT
    );

    text(
        margin + 95,
        205,
        "LUMA",
        3,
        COLOR_TEXT
    );

    text(
        margin + 95,
        238,
        "FRAMEWORK 2",
        2,
        COLOR_MUTED
    );

    text(
        margin + 30,
        292,
        "SYSTEM READY",
        2,
        COLOR_GREEN
    );


    /* card 2 */

    int card2_x =
        margin + card_w + gap;

    rounded_rect(
        card2_x,
        175,
        card_w,
        card_h,
        24,
        COLOR_CARD
    );

    circle(
        card2_x + 55,
        225,
        25,
        COLOR_BLUE
    );

    text(
        card2_x + 95,
        205,
        "LINUX",
        3,
        COLOR_TEXT
    );

    text(
        card2_x + 95,
        238,
        "6.18.49",
        2,
        COLOR_MUTED
    );

    text(
        card2_x + 30,
        292,
        "KERNEL ONLINE",
        2,
        COLOR_BLUE
    );


    /* bottom dock */

    int dock_w = 330;
    int dock_h = 92;

    int dock_x =
        (w - dock_w) / 2;

    int dock_y =
        h - 125;

    rounded_rect(
        dock_x,
        dock_y,
        dock_w,
        dock_h,
        35,
        COLOR_DARK
    );

    circle(
        dock_x + 55,
        dock_y + 46,
        25,
        COLOR_GREEN
    );

    circle(
        dock_x + 128,
        dock_y + 46,
        25,
        COLOR_BLUE
    );

    circle(
        dock_x + 201,
        dock_y + 46,
        25,
        COLOR_ORANGE
    );

    circle(
        dock_x + 274,
        dock_y + 46,
        25,
        COLOR_ACCENT
    );
}


static void draw_message(const char *message)
{
    int w = vinfo.xres;
    int h = vinfo.yres;

    rect(
        0,
        0,
        w,
        h,
        COLOR_BG
    );

    rounded_rect(
        60,
        h / 2 - 100,
        w - 120,
        200,
        30,
        COLOR_CARD
    );

    text(
        100,
        h / 2 - 30,
        message,
        3,
        COLOR_TEXT
    );
}


/* ------------------------------------------------------------
 * Command handler
 * ------------------------------------------------------------ */

static void process_command(
    int client,
    const char *command
)
{
    if (
        strcmp(
            command,
            "HOME"
        ) == 0
    ) {

        draw_home();

        write(
            client,
            "OK HOME\n",
            8
        );

    } else if (
        strcmp(
            command,
            "CLEAR"
        ) == 0
    ) {

        rect(
            0,
            0,
            vinfo.xres,
            vinfo.yres,
            COLOR_BG
        );

        write(
            client,
            "OK CLEAR\n",
            9
        );

    } else if (
        strncmp(
            command,
            "MESSAGE ",
            8
        ) == 0
    ) {

        draw_message(
            command + 8
        );

        write(
            client,
            "OK MESSAGE\n",
            11
        );

    } else {

        const char *error =
            "ERROR UNKNOWN UI COMMAND\n";

        write(
            client,
            error,
            strlen(error)
        );
    }
}


/* ------------------------------------------------------------
 * Main
 * ------------------------------------------------------------ */

int main(void)
{
    signal(SIGTERM, signal_handler);
    signal(SIGINT, signal_handler);


    fb_fd = open(
        "/dev/fb0",
        O_RDWR
    );

    if (fb_fd < 0) {

        perror(
            "lumaui: cannot open /dev/fb0"
        );

        return 1;
    }


    if (
        ioctl(
            fb_fd,
            FBIOGET_FSCREENINFO,
            &finfo
        ) < 0
    ) {

        perror(
            "lumaui: FBIOGET_FSCREENINFO"
        );

        return 1;
    }


    if (
        ioctl(
            fb_fd,
            FBIOGET_VSCREENINFO,
            &vinfo
        ) < 0
    ) {

        perror(
            "lumaui: FBIOGET_VSCREENINFO"
        );

        return 1;
    }


    fb_size =
        finfo.line_length *
        vinfo.yres_virtual;


    fb = mmap(
        NULL,
        fb_size,
        PROT_READ | PROT_WRITE,
        MAP_SHARED,
        fb_fd,
        0
    );


    if (fb == MAP_FAILED) {

        perror(
            "lumaui: mmap"
        );

        return 1;
    }


    printf(
        "[lumaui] framebuffer %ux%u %ubpp\n",
        vinfo.xres,
        vinfo.yres,
        vinfo.bits_per_pixel
    );


    mkdir(
        "/run/luma",
        0755
    );


    unlink(
        LUMA_UI_SOCKET_PATH
    );


    int server = socket(
        AF_UNIX,
        SOCK_STREAM,
        0
    );


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
        LUMA_UI_SOCKET_PATH,
        sizeof(address.sun_path) - 1
    );


    if (
        bind(
            server,
            (struct sockaddr *)&address,
            sizeof(address)
        ) < 0
    ) {

        perror(
            "lumaui: bind"
        );

        return 1;
    }


    chmod(
        LUMA_UI_SOCKET_PATH,
        0666
    );


    listen(
        server,
        8
    );


    draw_home();


    printf(
        "[lumaui] Luma UI ready\n"
    );


    while (running) {

        int client =
            accept(
                server,
                NULL,
                NULL
            );


        if (client < 0) {

            if (
                errno == EINTR
            )
                continue;

            break;
        }


        char buffer[1024];

        ssize_t bytes =
            read(
                client,
                buffer,
                sizeof(buffer) - 1
            );


        if (bytes > 0) {

            buffer[bytes] = '\0';


            while (
                bytes > 0 &&
                (
                    buffer[bytes - 1] == '\n' ||
                    buffer[bytes - 1] == '\r'
                )
            ) {

                buffer[
                    bytes - 1
                ] = '\0';

                bytes--;
            }


            process_command(
                client,
                buffer
            );
        }


        close(client);
    }


    munmap(
        fb,
        fb_size
    );

    close(
        fb_fd
    );

    unlink(
        LUMA_UI_SOCKET_PATH
    );


    return 0;
}
