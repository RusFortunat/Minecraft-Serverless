FROM alpine:3.20
RUN apk add --no-cache bash aws-cli jq net-tools
COPY watchdog.sh /watchdog.sh
RUN chmod +x /watchdog.sh
ENTRYPOINT ["/watchdog.sh"]
