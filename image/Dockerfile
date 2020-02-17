FROM tmate/tmate-ssh-server:latest

ADD create_keys.sh /etc/tmate/
ADD docker-entrypoint.sh /usr/local/bin/
RUN apk update && apk add openssh-keygen



