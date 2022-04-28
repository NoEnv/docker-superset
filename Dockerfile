FROM python:3.8-slim

# Superset version
ARG SUPERSET_VERSION=1.5.0

LABEL maintainer "NoEnv"
LABEL version "${SUPERSET_VERSION}"
LABEL description "Superset Docker Image"

# Configure environment
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONPATH=/etc/superset:/home/superset:$PYTHONPATH \
    SUPERSET_VERSION=${SUPERSET_VERSION} \
    SUPERSET_HOME=/var/lib/superset \
    FLASK_APP=superset.app:create_app()

# Create superset user & install dependencies
RUN useradd -U -m superset && \
    mkdir -p /etc/superset /tmp/requirements ${SUPERSET_HOME} && \
    chown -R superset:superset /etc/superset ${SUPERSET_HOME} && \
    apt-get update && \
    apt-get install -y \
        build-essential \
        libldap2-dev \
        libsasl2-dev \
        libssl-dev \
        libffi-dev \
        curl \
        python3-pil \
        python-dev && \
    curl -s https://raw.githubusercontent.com/apache/incubator-superset/${SUPERSET_VERSION}/requirements/base.txt \
        -o /tmp/requirements/base.txt && \
    curl -s https://raw.githubusercontent.com/apache/incubator-superset/${SUPERSET_VERSION}/requirements/docker.txt \
        -o /tmp/requirements/docker.txt && \
    sed -i '/-e file/d' /tmp/requirements/base.txt /tmp/requirements/docker.txt && \
    pip install --upgrade --no-cache-dir pip && \
    pip install --no-cache-dir pip -r /tmp/requirements/docker.txt && \
    pip install --no-cache-dir \
        pillow==9.1.0 \
        python-ldap==3.4.0 \
        clickhouse-sqlalchemy==0.1.8 \
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
WORKDIR /home/superset

# Deploy application
EXPOSE 8088
HEALTHCHECK CMD ["curl", "-f", "http://localhost:8088/health"]
ENTRYPOINT ["superset-run"]
USER superset
