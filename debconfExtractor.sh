#!/bin/sh
grep -e '^Template:' -e '^Type:' -e '^Default:' \
 /var/lib/dpkg/info/$1.templates | xargs | sed \
 -e 's/\s*Template: /\npackagename\t/g' \
 -e 's/\s*Type: */\t/g' \
 -e 's/\s*Default: */\t/g' | tee $1.conf
 