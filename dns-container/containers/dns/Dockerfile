FROM alpine:latest

RUN apk add bind bind-dnssec-tools

EXPOSE 53/tcp 53/udp

#CMD ["/usr/bin/named-checkconf", "-v"]
#CMD ["/usr/bin/named-checkconf", "-t", "/etc/bind", "named.conf"]
CMD ["named", "-c", "/etc/bind/named.conf", "-g", "-u", "named"]
