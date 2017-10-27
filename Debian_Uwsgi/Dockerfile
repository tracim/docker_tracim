FROM debian:latest
MAINTAINER contact@algoo.fr

ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
ENV LC_ALL C.UTF-8

VOLUME ["/etc/tracim", "/var/tracim"]

COPY uwsgi.ini /etc/tracim/uwsgi.ini
COPY nginx.conf /etc/tracim/nginx.conf
COPY wsgi.py /tracim/tracim/wsgi.py
COPY check_env_vars.sh /tracim/check_env_vars.sh
COPY common.sh /tracim/common.sh
COPY entrypoint.sh /tracim/entrypoint.sh

# Install required packages
RUN apt update -q && apt install -yq \
        git \
        realpath \
        redis-server \
        python3 \
        python3-dev \
        python3-pip  \
        python-lxml \
        build-essential \
        libxml2-dev \
        libxslt1-dev \
        zlib1g-dev \
        libjpeg-dev \
        uwsgi \
        curl \
        uwsgi-plugin-python3 \
        openjdk-8-jre-headless \
        libmagickwand-dev \
        postgresql-server-dev-all \
        postgresql \
        postgresql-client \
        mysql-server \
        nginx \
    && echo INFO: packages installations OK \
# Clone from GitHub
    && cd /tracim/ \
    # as /tracim/ already exists, we can't use standard git clone
    && git init \
    && git remote add origin http://github.com/tracim/tracim.git \
    && git pull origin master \
    && git status \
    && echo INFO: repository cloning OK \
# Install Node.js
    && curl -sL https://deb.nodesource.com/setup_7.x | bash - \
    && apt install -yq nodejs \
    && npm install \
    && npm run gulp-dev \
    && echo INFO: Node.js step OK \
# Install Tracim
    && pip3 install -r install/requirements.txt \
    && pip3 install -r install/requirements.mysql.txt \
    && pip3 install -r install/requirements.postgresql.txt \
    && echo INFO: pip installations OK \
    && cd /tracim/tracim \
    && python3 setup.py develop \
# Translation
    && python3 setup.py compile_catalog \
# Conf files
    && cp /tracim/tracim/development.ini.base /tracim/tracim/development.ini \
    && cp /tracim/tracim/wsgidav.conf.sample /tracim/tracim/wsgidav.conf \
# Init DB schema
    && gearbox setup-app --debug \
# Prepare volumes
    && mkdir /etc/tracim -p \
    && mkdir /var/tracim/logs -p \
    && mkdir /var/tracim/assets -p \
    && echo INFO: Volumes step OK \
# Init config files
    && rm /etc/nginx/sites-enabled/default \
    && ln -s /etc/tracim/uwsgi.ini /etc/uwsgi/apps-available/tracim.ini \
    && ln -s /etc/uwsgi/apps-available/tracim.ini /etc/uwsgi/apps-enabled/tracim.ini \
    && ln -s /etc/tracim/nginx.conf /etc/nginx/sites-available/tracim.conf \
    && ln -s /etc/nginx/sites-available/tracim.conf /etc/nginx/sites-enabled/tracim.conf \
    && chown root:www-data -R /var/tracim/logs \
    && chmod 775 -R /var/tracim/logs \
# Purges useless packages post-install
    && rm -rf /var/lib/apt/list/* \
    && apt purge -yg curl \
    && apt clean -q \
    && echo INFO: Package purge step OK \
    && chmod 755 /tracim/entrypoint.sh \
    && chmod +x /tracim/entrypoint.sh

CMD ["/bin/bash","/tracim/entrypoint.sh"]
