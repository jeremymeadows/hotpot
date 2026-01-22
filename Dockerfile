FROM debian:latest

WORKDIR /app

COPY ./build/bin/hotpot_server.x86_64 ./

EXPOSE 8910

CMD ["/app/hotpot_server.x86_64"]
