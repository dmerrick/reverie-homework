#!/bin/bash

# this script sets up the cron schedule and kicks
# off the cron process

echo "Entrypoint script has started"

# setup a cron schedule
echo "* * * * * /reverie/ping.sh >> /var/log/cron.log 2>&1
*/5 * * * * /reverie/upload.sh >> /var/log/cron.log 2>&1
# This extra line is required" > schedule.txt

# load the schedule into cron
crontab schedule.txt

# start cron process
cron -f
