FROM golang as builder
RUN mkdir /git
WORKDIR /git
RUN git clone https://github.com/carlespla/bareos_exporter
WORKDIR /git/bareos_exporter
RUN rm go.mod go.sum
RUN go mod init github.com/carlespla/bareos_exporter
RUN go mod tidy
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o bareos_exporter .

FROM busybox:latest

ENV mysql_port 3306
ENV mysql_server 192.168.3.70
ENV mysql_username monty
ENV endpoint /metrics
ENV port 9625

WORKDIR /bareos_exporter
COPY --from=builder /git/bareos_exporter bareos_exporter
RUN chmod +x bareos_exporter

CMD ./bareos_exporter -port $port -endpoint $endpoint -u $mysql_username -h $mysql_server -P $mysql_port -p pw/auth
EXPOSE $port
