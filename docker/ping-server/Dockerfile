FROM ubuntu:latest
MAINTAINER Dana Merrick

# install cron and awscli
RUN apt-get update && apt-get install -y cron awscli curl

RUN mkdir /reverie

# add the required scripts
ADD entrypoint.sh /reverie/entrypoint.sh
ADD ping.sh /reverie/ping.sh
ADD upload.sh /reverie/upload.sh

# make the scripts executable
RUN chmod +x /reverie/entrypoint.sh /reverie/ping.sh /reverie/upload.sh

# kick off the container
ENTRYPOINT /reverie/entrypoint.sh
