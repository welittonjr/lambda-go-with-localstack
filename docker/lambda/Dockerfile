FROM golang:1.21-alpine

WORKDIR /app 

RUN apk add --no-cache \
    curl \
    wget \
    git \
    zip 

COPY . .

EXPOSE 8080
EXPOSE 2345

CMD ["sleep", "infinity"]