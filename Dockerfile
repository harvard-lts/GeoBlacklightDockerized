FROM phusion/passenger-ruby32:latest
ENV TZ=America/New_York
ENV DEBIAN_FRONTEND noninteractive
ARG APP_ID_NAME=app
ARG SAN_LIST="[SAN]\nsubjectAltName=DNS:*.library.example.org,DNS:*.example.com"
ARG CERT_STRING="/C=US/ST=Massachusetts/L=Boston/O=Example Company/CN=*.example.org"

COPY --chown=app:app . /home/app/webapp

RUN apt-get update -qq && \
    apt-get install -y \
                       cmake \
                       gcc \
                       pkg-config \
                       zlib1g-dev \
                       netcat \
                       build-essential \
                       libssl-dev \
                       libcurl4-openssl-dev \
                       libreadline-dev \
                       libyaml-dev \
                       libxml2-dev \
                       libxslt1-dev \
                       libcurl4-openssl-dev \
                       software-properties-common \
                       shared-mime-info \
                       libffi-dev \
                       nodejs \
                       yarn \
                       imagemagick \
                       libpq-dev \
                       libsasl2-dev \
                       mariadb-client \
                       rsync \
                       tzdata \
                       unzip \
                       && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    printf ${SAN_LIST} >> /etc/ssl/openssl.cnf && \
    rm -f /etc/nginx/sites-enabled/default && \
    rm -f /etc/service/nginx/down && \
    chmod +x /home/app/webapp/bin/*.sh && \
    chown app /etc/ssl/certs && \
    chown app /etc/ssl/openssl.cnf && \
    chown -R app:app /etc/container_environment && \
    chmod -R 755 /etc/container_environment && \
    chown app:app /etc/container_environment.sh /etc/container_environment.json && \
    chmod 644 /etc/container_environment.sh /etc/container_environment.json && \
    chown -R app:app /var/log/nginx && \
    chown -R app:app /var/lib/nginx && \
    chown -R app:app /run    

USER ${APP_ID_NAME}

WORKDIR /home/app/webapp

RUN gem update --system && \
    bundle install && \
    mkdir -p /home/app/webapp/tmp/cache/downloads && \
    chmod g+s /home/app/webapp/tmp/cache && \
    chmod 755 /home/app/webapp/tmp/cache/downloads && \
    mkdir -p /home/app/webapp/tmp/pids && \
  openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 -subj "$CERT_STRING" -extensions SAN -reqexts SAN -config /etc/ssl/openssl.cnf -keyout /etc/ssl/certs/server.key -out /etc/ssl/certs/server.pem

CMD ["passenger", "start", "--port", "4000", "--log-file", "/dev/stdout", "--no-install-runtime", "--no-compile-runtime","--ssl","--ssl-certificate","/etc/ssl/certs/server.pem","--ssl-certificate-key","/etc/ssl/certs/server.key","--max-pool-size", "15", "--min-instances", "15", "--nginx-config-template","ops/nginx.conf.erb"]
