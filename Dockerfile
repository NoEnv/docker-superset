FROM python:3.9-slim

ARG SUPERSET_VERSION=3.0.3

LABEL maintainer "NoEnv"
LABEL version "${SUPERSET_VERSION}"
LABEL description "Superset Docker Image"

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONPATH=/etc/superset:/home/superset:$PYTHONPATH \
    SUPERSET_VERSION=${SUPERSET_VERSION} \
    SUPERSET_HOME=/var/lib/superset \
    FLASK_APP=superset.app:create_app()

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
        unzip \
        python3-pil \
        python-dev-is-python3 && \
    curl -s https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o /tmp/google-chrome-stable_current.deb && \
    apt-get install -y --no-install-recommends /tmp/google-chrome-stable_current.deb && \
    export CHROMEDRIVER_VERSION=$(curl -s https://chromedriver.storage.googleapis.com/LATEST_RELEASE) && \
    curl -s https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip -o /tmp/chromedriver.zip && \
    unzip /tmp/chromedriver.zip -d /usr/local/bin && \
    chmod 755 /usr/local/bin/chromedriver && \
    curl -s https://raw.githubusercontent.com/apache/incubator-superset/${SUPERSET_VERSION}/requirements/base.txt \
        -o /tmp/requirements/base.txt && \
    curl -s https://raw.githubusercontent.com/apache/incubator-superset/${SUPERSET_VERSION}/requirements/docker.txt \
        -o /tmp/requirements/docker.txt && \
    sed -i '/-e file/d' /tmp/requirements/base.txt /tmp/requirements/docker.txt && \
    pip install --upgrade --no-cache-dir pip && \
    pip install --no-cache-dir pip -r /tmp/requirements/docker.txt && \
    pip install --no-cache-dir \
        pillow==9.5.0 \
        python-ldap==3.4.4 \
        clickhouse-connect==0.6.23 \
        sqlalchemy-redshift==0.8.14 \
        requests==2.31.0 \
        Authlib==1.3.0 \
        apache-superset==${SUPERSET_VERSION} && \
    apt-get --purge autoremove -y \
        build-essential \
        libldap2-dev \
        libsasl2-dev \
        libssl-dev \
        libffi-dev \
        unzip \
        python-dev && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* /tmp/google-chrome-stable_current.deb /tmp/chromedriver.zip

COPY superset /usr/local/bin
WORKDIR /home/superset

EXPOSE 8088
CMD ["superset-run"]
USER superset
