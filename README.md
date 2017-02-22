## Tracim with Docker

### Build images

To build tests designed image

    docker build -t algoo/tracim_test:tests ./Debian_Tests

To build Prod/dev designed image

    docker build -t algoo/tracim:latest ./Debian_Uwsgi

### Run containers

#### Run tests containers

Run tests with PostgreSQL

    docker run -e TEST_DATABASE_ENGINE=postgresql algoo/tracim_test

Run tests with MySQL

    docker run -e TEST_DATABASE_ENGINE=mysql algoo/tracim_test

Run tests with SQLite

    docker run -e TEST_DATABASE_ENGINE=sqlite algoo/tracim_test

##### Run test on specific commit/branch

To run tests on specific branch or commit, use ``CHECKOUT`` parameter, eg:

    docker run -e TEST_DATABASE_ENGINE=postgresql -e CHECKOUT=<branch_or_commit_name> algoo/tracim_test

##### Other parameters (environment variables)

* FETCH: (0 or 1) Apply a ``git fetch origin`` on tracim repository
* PULL: (0 or 1) Apply a ``git pull origin master`` on tracim repository to set tracim on latest master branch

#### Run Prod/dev containers

Environment variables are:

* PULL (0 or 1): If 1, upgrade tracim at startup
* DATABASE_TYPE (values: postgresql, mysql, sqlite)

If DATABASE_TYPE is `postgresql` or `mysql`, please set these variables:

* DATABASE_USER
* DATABASE_PASSWORD
* DATABASE_HOST
* DATABASE_PORT
* DATABASE_NAME

Volumes are:

* /etc/tracim
* /var/tracim (used for SQLite database and radicale)

Ports are:

* 80 (industracim web interface)

To run tracim container with MySQL or PostgreSQL, you must set environment ``DATABASE_USER, DATABASE_PASSWORD, DATABASE_HOST, DATABASE_PORT, DATABASE_NAME`` variable.
Example with PostgreSQL:

    docker run -e DATABASE_TYPE=postgresql -e DATABASE_USER=tracim -e DATABASE_PASSWORD=tracim -e DATABASE_HOST=192.168.1.2 -e DATABASE_NAME=tracim -p 80:80 -v /tmp/tracim:/etc/tracim algoo/tracim

Example with MySQL

    docker run -e DATABASE_TYPE=mysql -e DATABASE_USER=tracim -e DATABASE_PASSWORD=tracim -e DATABASE_HOST=192.168.1.2 -e DATABASE_NAME=tracim -p 80:80 -v /tmp/tracim:/etc/tracim algoo/tracim

Example with SQLite

    docker run -e DATABASE_TYPE=sqlite -p 80:80 -v /tmp/tracim:/etc/tracimetc -v /tmp/tracimvar:/var/tracim algoo/tracim

After execute one of these command, tracim will be available on your system on port 80.
