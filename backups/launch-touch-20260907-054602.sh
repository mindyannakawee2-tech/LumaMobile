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


echo "[LumaARM] starting LumaShell"


exec \
    /usr/bin/lumashell

