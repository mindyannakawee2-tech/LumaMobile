#!/bin/sh


echo "[LumaARM] waiting for display"


FRAMEBUFFER=""


i=0

while [ "$i" -lt 200 ]
do

    for SYSFB in /sys/class/graphics/fb*
    do

        [ -e "$SYSFB" ] || continue


        FB="$(
            basename "$SYSFB"
        )"


        NAME="$(
            cat "$SYSFB/name" 2>/dev/null
        )"


        echo \
            "[LumaARM] $FB = $NAME"


        case "$NAME" in

            *ili9486*|*piscreen*|*fb_ili*|*fbtft*)

                FRAMEBUFFER="/dev/$FB"

                break
                ;;

        esac

    done


    [ -n "$FRAMEBUFFER" ] && break


    # Fallback if only one framebuffer exists.

    if [ -e /dev/fb0 ]; then
        FRAMEBUFFER=/dev/fb0
        break
    fi


    if [ -e /dev/fb1 ]; then
        FRAMEBUFFER=/dev/fb1
        break
    fi


    sleep 0.1

    i=$((i + 1))

done


if [ -z "$FRAMEBUFFER" ]; then

    echo \
        "[LumaARM] ERROR: no framebuffer after 20 seconds"

    exit 100

fi


echo \
    "[LumaARM] framebuffer = $FRAMEBUFFER"


mkdir -p \
    /run/luma-shell \
    /data/home/luma


chmod 0700 \
    /run/luma-shell


export HOME=/data/home/luma

export XDG_RUNTIME_DIR=/run/luma-shell


# ============================================================
# Reliable software graphics first.
# ============================================================

export QT_QPA_PLATFORM="linuxfb:fb=$FRAMEBUFFER"

export QT_QUICK_BACKEND=software

export QT_QPA_FB_HIDECURSOR=1


#
# Do NOT force a particular touchscreen plugin yet.
# Raspberry Pi OS/Qt can discover evdev/libinput devices.
# This avoids making an incorrect XPT mapping prevent boot.
#



# LUMA_TOUCH_FINAL_BEGIN
# ============================================================
# LumaMobile Touch Pipeline
#
# RAW XPT2046
#      ↓
# Linux input
#      ↓
# libinput
#      ↓
# Qt horizontal-flip matrix
#      ↓
# LumaShell
#
# There must be NO other coordinate transformation.
# ============================================================


# ------------------------------------------------------------
# Disable every previous experimental input path.
# ------------------------------------------------------------

unset QT_QPA_FB_TSLIB
unset QT_QPA_EGLFS_TSLIB
unset QT_QPA_TSLIB

unset TSLIB_TSDEVICE
unset TSLIB_CALIBFILE
unset TSLIB_CONFFILE
unset TSLIB_FBDEVICE

unset QT_QPA_GENERIC_PLUGINS
unset QT_QPA_EVDEV_TOUCHSCREEN_PARAMETERS

unset QT_QPA_NO_LIBINPUT
unset QT_QPA_EGLFS_NO_LIBINPUT


# ------------------------------------------------------------
# Horizontal mirror correction.
#
# x' = 1 - x
# y' = y
#
# Matrix:
#
#    -1  0  1
#     0  1  0
#     0  0  1
#
# Qt expects the first two rows.
# ------------------------------------------------------------

export QT_QPA_LIBINPUT_TOUCH_MATRIX="-1 0 1 0 1 0"


# Input debugging stays enabled for now.

export QT_LOGGING_RULES="qt.qpa.input=true"


echo "[LumaTouch] input backend = libinput"
echo "[LumaTouch] matrix = $QT_QPA_LIBINPUT_TOUCH_MATRIX"

# LUMA_TOUCH_FINAL_END


echo "[LumaARM] starting LumaShell"


exec \
    /usr/bin/lumashell

