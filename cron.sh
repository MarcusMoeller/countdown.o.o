#!/bin/bash
REMOTE_HOST="counter.o.o"
BASEDIR="/home/counter.opensuse.org/svg"
LOCAL="/home/counter.opensuse.org/output"
REMOTE="counter.o.o:/srv/www/vhosts/0b965c33b89fac9ea53708de378f93dcda084d34/opensuse.org/counter/htdocs"

set -e

VERBOSE=''
RENDER=1
while getopts 'vRE' v; do
    case $v in
        v) VERBOSE=1;;
        R) REMOTE='';;
        E) RENDER='';;
        *) echo "ERROR: unsupported parameter -$v">&2; exit 1;;
    esac
done
shift $(( $OPTIND - 1 ))

RFLAGS=""
[ -n "$VERBOSE" ] && RFLAGS="$RFLAGS -v"

cd "$BASEDIR"
mkdir -p "$LOCAL"
if [ -n "$RENDER" ]; then
    /bin/rm -f "$LOCAL"/*.png
    ./render.py $RFLAGS "$LOCAL"/ || exit 1
    pushd "$LOCAL" >/dev/null
    find . -maxdepth 1 -type f -name '*.png' | while read png; do
	[ -n "$VERBOSE" ] && echo "optipng $png"
        optipng "$png" &>/dev/null
    done
    popd >/dev/null

    for f in *.html *.css *.js; do
        [ -e "$f" ] || continue
        cp -a "$f" "$LOCAL/"
    done
fi

if [ -n "$REMOTE" ]; then
    RSFLAGS=""
    [ -n "$VERBOSE" ] && RSFLAGS="$RSFLAGS -v"
    rsync -ap --delete-after $RSFLAGS "$LOCAL/" "$REMOTE/"
fi

