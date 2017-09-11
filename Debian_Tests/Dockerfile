FROM debian:latest
MAINTAINER contact@algoo.fr

#TODO @Damien: processus d'install (pip) plein de warning et d'erreur de compilation non fatals. 

#Install required packages
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
	libmagickwand-dev \
	postgresql-server-dev-all \
	postgresql \
	postgresql-client \
	mysql-server \
	libmariadbd-dev \
	libmariadbclient-dev-compat \
	openjdk-8-jre \
	nginx
	
# Ensure UTF-8
RUN locale-gen en_US.UTF-8 en_us \
	&& dpkg-reconfigure locales \
	&& locale-gen C.UTF-8 \
	&& /usr/sbin/update-locale LANG=C.UTF-8
ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
ENV LC_ALL C.UTF-8

#Get the source from GitHub
RUN git clone http://github.com/tracim/tracim.git \
	&& cd /tracim/

#Install node js
RUN curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash - \
	&& apt install -yq nodejs \
#Check npm version
	&& npm -v \
	&& cd /tracim/ \
#Install frontend dependencies
	&& npm install \
#Compile them
	&& npm run gulp-dev # for a development environment 

#Install Tracim and its dependencies
RUN cd /tracim/tracim \
	&& python3 setup.py develop 
RUN cd /tracim/ \
	&& pip3 install -r install/requirements.txt \
	&& pip3 install -r install/requirements.mysql.txt \
	&& pip3 install -r install/requirements.postgresql.txt \
	&& pip3 install mysqlclient

#Conf files
RUN cp /tracim/tracim/development.ini.base /tracim/tracim/development.ini \
	&& cp /tracim/tracim/wsgidav.conf.sample /tracim/tracim/wsgidav.conf

#DB schema
RUN cd /tracim/tracim/ && gearbox setup-app --debug
RUN cd /tracim/doc/ && echo ALTER SCHEMA tracimdb DEFAULT CHARACTER SET utf8 >> database.md

#Prepare volumes
RUN mkdir /etc/tracim \
	&& mkdir /var/tracim \
	&& mkdir /var/tracim/logs \
	&& mkdir /var/tracim/assets
VOLUME ["/etc/tracim", "/var/tracim"]

COPY uwsgi.ini /etc/tracim/uwsgi.ini
COPY nginx.conf /etc/tracim/nginx.conf
COPY wsgi.py /tracim/tracim/wsgi.py
COPY check_env_vars.sh /tracim/check_env_vars.sh
COPY common.sh /tracim/common.sh
COPY entrypoint.sh /tracim/entrypoint.sh

RUN ln -s /etc/tracim/uwsgi.ini /etc/uwsgi/apps-available/tracim.ini \
&& ln -s /etc/uwsgi/apps-available/tracim.ini /etc/uwsgi/apps-enabled/tracim.ini \
&& ln -s /etc/tracim/nginx.conf /etc/nginx/sites-available/tracim.conf \
&& ln -s /etc/nginx/sites-available/tracim.conf /etc/nginx/sites-enabled/tracim.conf \ 
&& chown root:www-data -R /var/tracim/logs \
&& chmod 775 -R /var/tracim/logs \
&& rm /etc/nginx/sites-enabled/default \
&& chmod 755 /tracim/entrypoint.sh

CMD ["/tracim/entrypoint.sh"]
