# -*- coding: utf-8 -*-
#
# Cookbook Name:: sentry cookbook
#
# :copyright: (c) 2012 - 2013 by Alexandr Lispython (alex@obout.ru).
# :license: BSD, see LICENSE for more details.
# :github: http://github.com/Lispython/sentry-cookbook
#

default["sentry"]["include_settings"] = nil
default["sentry"]["version"]="5.1.2"
default["sentry"]["virtualenv"] = "/var/www/sentry"
default["sentry"]["user"] = "sentry"
default["sentry"]["group"] = "sentry"

default["sentry"]["plugins"] = [
  "sentry.plugins.sentry_mail",
  "sentry.plugins.sentry_servers",
  "sentry.plugins.sentry_urls",
  "sentry.plugins.sentry_useragents"]

default["sentry"]["3_party_plugins"] = {}

default["sentry"]["config"] = "/etc/sentry.conf.py"

default["sentry"]["superuser_creator_script"] = "/tmp/superuser_creator.py"
default["sentry"]["superusers"] = []

# Database settings
default["sentry"]["databases"]["default"] = {
  "ENGINE" => "django.db.backends.sqlite3",
  "NAME" => "sentry",
  "USER" => "sentry",
  "PASSWORD" => "",
  "HOST" => "",
  "PORT" => ""
}

default["sentry"]["public"] = 'True'
default["sentry"]["prefix"] = "http://sentry.example.com"
default["sentry"]["key"] = "generate_you_own_key"

# Server settings
default["sentry"]["web"] = {
  "host" => "0.0.0.0",
  "port" => 9000,
  "options" => {
    "workers" => 3,
    #"worker_class": "gevent"
  }
}


default['sentry']['social_auth_create_users'] = 'True'

# Email settings
default["sentry"]["email"] = {
  "backend" => 'django.core.mail.backends.smtp.EmailBackend',
  "host" => "localhost",
  "password" => '',
  "user" => '',
  "port" => 25,
  "use_tls" => 'False',
}


# Social settings
default["sentry"]["social"] = {
"twitter" => {
  "consumer_key" => '',
  "consumer_secret" => ''},

# http://developers.facebook.com/setup/
"facebook" => {
  "app_id" => '',
  "api_secret" => ''
},

# http://code.google.com/apis/accounts/docs/OAuth2.html#Registering
"google_oauth" => {
  "client_id" => '',
  "client_secret" => ''
},

# https://github.com/settings/applications/new
"github" => {
  "app_id" => '',
  "api_secret" => ''
},

# https://trello.com/1/appKey/generate
"trello" => {
  "api_key" => '',
  "api_secret" => ''
}
}

default["sentry"]["custom_settings"] = {"test" => "value"}

default["sentry"]["start"] = false
default["sentry"]["spawner"] = "#{default[:sentry][:virtualenv]}/bin/spawner"
default["sentry"]["init.d"] = {
  "pidfile" => "/var/run/sentry.pid",
  "script" => "/etc/init.d/sentry"
}

