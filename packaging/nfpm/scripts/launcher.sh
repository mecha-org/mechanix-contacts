#!/bin/sh
APPDIR="/usr/share/mechanix/mechanix-contacts"
exec "$APPDIR/mechanix_contacts" --bundle="$APPDIR" "$@"
