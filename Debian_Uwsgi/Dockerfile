FROM debian:latest
MAINTAINER contact@algoo.fr

# TODO @Damien: pip installs with warnings and compilation error.

# Env variable
ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
ENV LC_ALL C.UTF-8

# Install required packages
RUN apt update -q \
	&& apt install -yq sudo \
	git \
	locales \
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
	openjdk-8-jre \
	libmagickwand-dev \
	postgresql-server-dev-all \
	postgresql \
	postgresql-client \
	mysql-server \
	libmariadbd-dev \
	libmariadbclient-dev-compat \
	nginx \
	&& locale-gen en_US.UTF-8 en_us \
	&& dpkg-reconfigure locales \
	&& locale-gen C.UTF-8 \
	&& /usr/sbin/update-locale LANG=C.UTF-8 \
# Clone from GitHub
	&& git clone http://github.com/tracim/tracim.git \
	&& cd /tracim/ \
# Install Node.js
	&& curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash - \
	&& apt install -yq nodejs \
	&& npm install \
	&& npm run gulp-dev \
	&& echo INFO: Node.js step OK \
# Install Tracim
# BUG : command stops without Docker notifying it.
RUN cd /tracim/tracim \
	&& python3 setup.py develop \
	&& pip3 install -r install/requirements.txt \
	&& pip3 install -r install/requirements.mysql.txt \
	&& pip3 install -r install/requirements.postgresql.txt \
	&& pip3 install mysqlclient \
	&& echo INFO: pip installations OK \
# Conf files
	&& cp /tracim/tracim/development.ini.base /tracim/tracim/development.ini \
	&& cp /tracim/tracim/wsgidav.conf.sample /tracim/tracim/wsgidav.conf \
# Translation
	&& python3 setup.py compile_catalog
# Init DB schema
	&& gearbox setup-app --debug \
# Prepare volumes
	&& mkdir /etc/tracim \
	&& mkdir /var/tracim \
	&& mkdir /var/tracim/logs \
	&& mkdir /var/tracim/assets \
	&& echo INFO: Volumes step OK \
#Init config files
	&& ln -s /etc/tracim/uwsgi.ini /etc/uwsgi/apps-available/tracim.ini \
	&& ln -s /etc/uwsgi/apps-available/tracim.ini /etc/uwsgi/apps-enabled/tracim.ini \
	&& ln -s /etc/tracim/nginx.conf /etc/nginx/sites-available/tracim.conf \
	&& ln -s /etc/nginx/sites-available/tracim.conf /etc/nginx/sites-enabled/tracim.conf \
	&& chown root:www-data -R /var/tracim/logs \
	&& rm -rf /var/lib/apt/list/* \
	&& apt clean -q
# TODO remove useless packages post-install

VOLUME ["/etc/tracim", "/var/tracim"]

COPY uwsgi.ini /etc/tracim/uwsgi.ini
COPY nginx.conf /etc/tracim/nginx.conf
COPY wsgi.py /tracim/tracim/wsgi.py
COPY check_env_vars.sh /tracim/check_env_vars.sh
COPY common.sh /tracim/common.sh
COPY entrypoint.sh /tracim/entrypoint.sh

RUN chmod 775 -R /var/tracim/logs \
	&& rm /etc/nginx/sites-enabled/default \
	&& chmod 755 /tracim/entrypoint.sh \
	&& chmod +x /tracim/entrypoint.sh

CMD ["/bin/bash","/tracim/entrypoint.sh"]
