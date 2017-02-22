FROM algoo/tracim:latest
MAINTAINER contact@algoo.fr

RUN apt-get update -q \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
      openjdk-7-jre

COPY check_env_vars.sh /tracim/check_env_vars.sh
COPY entrypoint.sh /tracim/test.sh
CMD ["/tracim/test.sh"]
