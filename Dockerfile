FROM golang:1.21.5-alpine3.18 as builder

WORKDIR /app

COPY . .

RUN go build -o /usr/local/bin/temporal-server ./cmd/server

# Download the static build of Litestream directly into the path & make it executable.
# This is done in the builder and copied as the chmod doubles the size.
ADD https://github.com/benbjohnson/litestream/releases/download/v0.3.13/litestream-v0.3.13-linux-amd64.tar.gz /tmp/litestream.tar.gz
RUN tar -C /usr/local/bin -xzf /tmp/litestream.tar.gz

FROM alpine:3.18

RUN apk --no-cache add curl bash

RUN curl -sSL -o temporal.tar.gz "https://temporal.download/cli/archive/latest?platform=linux&arch=amd64" \
  && tar -C /tmp -xzf temporal.tar.gz \
  && cp /tmp/temporal /usr/local/bin/temporal \
  && chmod +x /usr/local/bin/temporal \
  && rm -rf /tmp/temporal

# Add Temporal CLI to PATH
ENV PATH="/usr/local/bin:${PATH}"

COPY --from=builder /usr/local/bin/litestream /usr/local/bin/litestream
COPY --from=builder /usr/local/bin/temporal-server /usr/local/bin/temporal-server

COPY  scripts/setup.sh /usr/local/bin/setup.sh
COPY  scripts /scripts
COPY  config /config
COPY  etc/litestream.yml /etc/litestream.yml

EXPOSE 7233

CMD [ "setup.sh" ]
ENTRYPOINT [ "/scripts/run.sh" ]
