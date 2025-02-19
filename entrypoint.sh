#!/bin/bash

set -e

source config.shlib;

TZ="$(config_get timezone)";
CRON_SCHEDULE="$(config_get crontab)";
CRON_SCHEDULE2="$(config_get crontab2)";
RUN_ONCE="$(config_get run_once)";
RUN_ON_STARTUP="$(config_get run_on_startup)";

echo "Setting timezone: $TZ"
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/$TZ /etc/localtime


echo "Run on startup: ${RUN_ON_STARTUP}"
if [ "$RUN_ON_STARTUP" = "true" ]; then
    /usr/local/bin/node /usr/src/app/index.js
    if [ "$RUN_ONCE" = "true" ]; then
    echo "Exiting..."
    exit 0
    fi
fi

echo "Run once: ${RUN_ONCE}"
if [ "$RUN_ONCE" = "false" ]; then
printenv | sed 's/^\(.*\)$/export \1/g' > /root/project_env.sh
echo "Setting cron schedule: ${CRON_SCHEDULE}"
crontab -l | { echo "${CRON_SCHEDULE} /bin/bash -c '/usr/local/bin/node /usr/src/app/index.js' > /proc/1/fd/1 2>/proc/1/fd/2"; echo "${CRON_SCHEDULE2} /bin/bash -c '/usr/src/app/config/merge.sh' > /proc/1/fd/1 2>/proc/1/fd/2"; } | crontab -
crond -f
else
node /usr/src/app/index.js
echo "Exiting..."
exit 0
fi
