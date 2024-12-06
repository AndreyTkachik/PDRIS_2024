FROM alpine:3.11
RUN apk add --no-cache openssh-client ansible git sshpass
RUN mkdir -p /root/.ssh
COPY ./ansible /ansible
WORKDIR /ansible
CMD [""]
