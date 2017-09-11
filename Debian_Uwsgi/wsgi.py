# -*- coding: utf-8 -*-

APP_CONFIG = '{{ instance.tracim_config_file_path }}'

# Setup logging
import logging
import logging.config
logging.config.fileConfig('/tmp/config.ini')

from paste.deploy import loadapp
application = loadapp('config:/tmp/config.ini')
application.debug = False
