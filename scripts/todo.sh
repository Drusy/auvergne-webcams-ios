#!/bin/sh

if [ "${CONFIGURATION}" = "Debug" ]; then
    TAGS="TODO:|FIXME:|WARNING:"
    echo "searching ${SRCROOT} for ${TAGS}"
    find "${SRCROOT}" -not -path "${SRCROOT}/Carthage/*" \( -name "*.swift" \) -print0 | xargs -0 egrep --with-filename --line-number --only-matching "($TAGS).*\$" |     perl -p -e "s/($TAGS)/ warning: \$1/"
fi
