FROM debian:latest

RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    lighttpd \
    pmake \
    exim4 \
    postgresql-client \
    python-pip \
    sudo \
    wget

RUN pip install markdown2

RUN wget -qO- http://www.public-software-group.org/pub/projects/liquid_feedback/backend/v3.1.0/liquid_feedback_core-v3.1.0.tar.gz | \
        tar -xz -C /usr/local/src/ && \
    cd /usr/local/src/liquid_feedback_core* && \
    make && \
    mkdir /opt/liquid_feedback_core && \
    cp core.sql demo.sql test.sql lf_update lf_update_issue_order lf_update_suggestion_order /opt/liquid_feedback_core
ADD admin-party.sql /opt/liquid_feedback_core/

ADD entrypoint.sh /opt/liquid_feedback_docker/
ADD bootstrap.sh /opt/liquid_feedback_docker/
RUN chmod 755 /opt/liquid_feedback_docker/*

ENTRYPOINT ["/opt/liquid_feedback_docker/entrypoint.sh"]

