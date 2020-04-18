FROM python:3.7-slim

# Superset version
ARG SUPERSET_VERSION=0.36.0

LABEL maintainer "NoEnv"
LABEL version "0.36.0"
LABEL description "Superset Docker Image"

# Configure environment
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONPATH=/etc/superset:/home/superset:$PYTHONPATH \
    SUPERSET_VERSION=${SUPERSET_VERSION} \
    SUPERSET_HOME=/var/lib/superset

# Create superset user & install dependencies
RUN useradd -U -m superset && \
    mkdir /etc/superset  && \
    mkdir ${SUPERSET_HOME} && \
    chown -R superset:superset /etc/superset && \
    chown -R superset:superset ${SUPERSET_HOME} && \
    apt-get update && \
    apt-get install -y \
        build-essential \
        libldap2-dev \
        libsasl2-dev \
        libssl-dev \
        libffi-dev \
        curl \
        python-dev && \
    curl -s https://raw.githubusercontent.com/apache/incubator-superset/${SUPERSET_VERSION}/requirements.txt \
        -o /tmp/requirements.txt && \
    pip install --upgrade --no-cache-dir pip && \
    pip install --no-cache-dir pip -r /tmp/requirements.txt && \
    pip install --no-cache-dir \
        python-ldap==3.2.0 \
        redis==3.2.1 \
        gevent==1.4.0 \
        infi.clickhouse-orm==1.3.0 \
        sqlalchemy-clickhouse==0.1.5.post0 \
        apache-superset==${SUPERSET_VERSION} && \
    apt-get --purge autoremove -y \
        build-essential \
        libldap2-dev \
        libsasl2-dev \
        libssl-dev \
        libffi-dev \
        python-dev && \
    apt-get clean -y && \
    rm -r /var/lib/apt/lists/*

# Configure Filesystem
COPY superset /usr/local/bin
VOLUME /home/superset \
       /etc/superset \
       /var/lib/superset
WORKDIR /home/superset

# Deploy application
EXPOSE 8088
HEALTHCHECK CMD ["curl", "-f", "http://localhost:8088/health"]
ENTRYPOINT ["superset-run"]
USER superset
