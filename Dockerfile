#Dockerfile for packaging up MTA-DAC content
FROM ubuntu:16.04 as builder

RUN apt-get update && apt-get install -y openssl

COPY . /content

ARG KEY

WORKDIR /content

RUN tar -czf - * | openssl enc -e -aes256 -k $KEY -out content.tar.gz

FROM broyal/md-secure-renderer:0.3

COPY --from=builder /content/content.tar.gz /app/content.tar.gz