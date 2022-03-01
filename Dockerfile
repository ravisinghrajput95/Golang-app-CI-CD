FROM golang:1.14.9-alpine
RUN mkdir /build
WORKDIR /build
ADD src/* ./
RUN go build
CMD [ "./build" ]