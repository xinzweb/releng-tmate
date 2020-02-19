FROM alpine:3.9
RUN apk add --update openssh-client

COPY create_keys.sh /usr/local/bin

ENTRYPOINT ["create_keys.sh"]
