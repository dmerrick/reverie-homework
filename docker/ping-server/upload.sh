#!/usr/bin/env bash

# this script takes a log file and uploads it
# to S3.
# it is intended to be run via cron.

#TODO: the ENV is hardcoded here and shouldn't be
BUCKET=reverie-hw-ping-logs-test
LOG="ping-$(date +%s).log"

cd /reverie

# move the latest pings to a new file
mv ping.log $LOG

# copy the new file to S3
aws s3 cp $LOG s3://${BUCKET}/

# remove the new file
rm $LOG
