#!/bin/sh

read_config() {
    FILE=$1
    KEY=$2
    LINE=$(grep "^$KEY=" $FILE)
    VALUE=${LINE#$KEY=}
}

DISPLAY_MANAGER=xdm
XCURSOR_THEME=

test -r /etc/default/xdm && . /etc/default/xdm
test -r /etc/conf.d/xdm && . /etc/conf.d/xdm

DM_PATH=
DESKTOP_FILE=/usr/share/display-managers/$DISPLAY_MANAGER.desktop

if [ -f $DESKTOP_FILE ]; then
    read_config $DESKTOP_FILE Exec
    DM_PATH=$VALUE
    read_config $DESKTOP_FILE X-Pardus-XCursorTheme
    test -n "$VALUE" && XCURSOR_THEME=$VALUE
fi

test -x "$DM_PATH" || DM_PATH=/usr/bin/xdm

PATH=/sbin:/usr/sbin:/bin:/usr/bin

test -f /etc/env.d/03locale && . /etc/env.d/03locale

export LC_ALL PATH XCURSOR_THEME

if test -eq "x$1" "x--boot" && grep -qw "xorg=safe"; then
    export XORGCONFIG=/usr/share/X11/xorg-safe.conf
fi

# Trigger events against a locale change. This is needed for
# determining the default keymap.
udevadm trigger --property-match=ID_INPUT_KEYBOARD=1

exec $DM_PATH -nodaemon
