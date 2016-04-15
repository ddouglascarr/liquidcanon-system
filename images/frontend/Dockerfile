FROM debian:latest

RUN apt-get -y update && apt-get install -y \
    build-essential \
    lua5.2 \
    li\bbsd-dev \
    liblua5.2-dev \
    libpq-dev \
    lighttpd \
    pmake \
    exim4 \
    postgresql-client \
    postgresql-server-dev-all \
    python-pip \
    sudo \
    wget

RUN pip install markdown2

# Install Moonbridge
RUN wget -qO- http://www.public-software-group.org/pub/projects/moonbridge/v1.0.1/moonbridge-v1.0.1.tar.gz | \
        tar -xz -C /usr/local/src/ && \
    cd /usr/local/src/moonbridge* && \
    pmake MOONBR_LUA_PATH=/opt/moonbridge/?.lua && \
    mkdir /opt/moonbridge && \
    cp moonbridge /opt/moonbridge/ && \
    cp moonbridge_http.lua /opt/moonbridge/ 

# Install WebMCP
#   - debian required the sed command
#   - debian stores psql-server libs in /usr/local/lib, not /usr/local/included/lib
RUN wget -qO- http://www.public-software-group.org/pub/projects/webmcp/v2.0.2/webmcp-v2.0.2.tar.gz | \
        tar -xz -C /usr/local/src/ && \
    cd /usr/local/src/webmcp* && \
    sed -i '/CFLAGS / s/$/ -I \/usr\/include\/lua5.2/' Makefile.options && \
    sed -i 's/\/usr\/local\/include\/postgresql/\/usr\/include\/postgresql/g' Makefile.options && \
    ln -s /usr/include/postgresql/9.4/server /usr/include/postgresql/server && \
    make && \
    mkdir /opt/webmcp && \
    cp -RL framework/* /opt/webmcp/


# Install frontend
RUN wget -qO- http://www.public-software-group.org/pub/projects/liquid_feedback/frontend/v3.1.0/liquid_feedback_frontend-v3.1.0.tar.gz | \
        tar -xz -C /opt/ && \
    mv /opt/liquid_feedback_frontend-* /opt/liquid_feedback_frontend && \
    chown www-data /opt/liquid_feedback_frontend/tmp

ADD run-server.sh /
RUN chmod 755 /run-server.sh

ENTRYPOINT ["/run-server.sh"]
EXPOSE 8080
