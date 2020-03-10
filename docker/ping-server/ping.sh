#!/usr/bin/env bash

# this script makes a request to a server and
# logs the response it gets.
# it is intended to be run via cron.

HOST=a20dfd45762e011ea88ca02c79780a90-1260875247.us-east-1.elb.amazonaws.com:8080

cd /reverie

# simply add the response to the ping log
curl --verbose "${HOST}" >> ping.log 2>&1
