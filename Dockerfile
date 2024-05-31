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

ENV sql_port 3306
ENV sql_server 127.0.0.1
ENV sql_username root
ENV endpoint /metrics
ENV port 9625

WORKDIR /bareos_exporter
COPY --from=builder /git/bareos_exporter bareos_exporter
RUN chmod +x /bareos_exporter/bareos_exporter/bareos_exporter


CMD ./bareos_exporter/bareos_exporter -port $port -endpoint $endpoint -u $sql_username -h $sql_server -P $sql_port -p pw/auth
EXPOSE $port
