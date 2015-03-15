# -*- coding: utf-8 -*-
#
# Cookbook Name:: sentry cookbook
#
# :copyright: (c) 2012 - 2013 by Alexandr Lispython (alex@obout.ru).
# :license: BSD, see LICENSE for more details.
# :github: http://github.com/Lispython/sentry-cookbook
#

# Global params
default["sentry"]["version"] = "6.3.0"
default["sentry"]["superuser_creator_script"] = "/tmp/superuser_creator.py"

default["sentry"]["include_settings"] = nil

default["sentry"]["user"] = "sentry"
default["sentry"]["group"] = "sentry"
#default["sentry"]["userhome"] = "/home/#{node["sentry"]["user"]}"
default["sentry"]["virtualenv"] = "/var/www/sentry"
default["sentry"]["userhome"] = node["sentry"]["virtualenv"]
default["sentry"]["config"] = "/etc/sentry.conf.py"
default["sentry"]["superusers"] = []
default["sentry"]["static_dir"] = "#{node["sentry"]["userhome"]}/static"

default["sentry"]["use_queue"] = false
# Sentry config settings
default["sentry"]["settings"] = {}

default["sentry"]["settings"]["plugins"] = [
                                            "sentry.plugins.sentry_mail",
                                            "sentry.plugins.sentry_sites",
                                            "sentry.plugins.sentry_urls",
                                            "sentry.plugins.sentry_useragents"]

default["sentry"]["settings"]["third_party_plugins"] = {}

# Database settings
default["sentry"]["settings"]["databases"] = {
  "default" => {
    "ENGINE" => "django.db.backends.sqlite3",
    "NAME" => "#{node["sentry"]["virtualenv"]}/default_sentry_db",
    "USER" => "sentry",
    "PASSWORD" => "",
    "HOST" => "",
    "PORT" => ""
  }}

default["sentry"]["settings"]["public"] = 'False'
default["sentry"]["settings"]["prefix"] = "http://sentry.example.com"
default["sentry"]["settings"]["private_key"] = "generate_you_own_key"


  # Server settings
default["sentry"]["settings"]["web"]= default["sentry"]["web"] = {
  "host" => "0.0.0.0",
  "port" => 9000,
  "options" => {
    "workers" => 3,
    #"worker_class": "gevent"
  }}

default["sentry"]["settings"]["social_auth_create_users"] = 'True'

# Email settings
default["sentry"]["settings"]["email"] = {
  "backend" => 'django.core.mail.backends.smtp.EmailBackend',
  "host" => "localhost",
  "password" => '',
  "user" => '',
  "port" => 25,
  "use_tls" => 'False',
}

  # Social settings
default["sentry"]["settings"]["social"] = {
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

default["sentry"]["settings"]["custom_settings"] = {}

# Instance settings
default["sentry"]["start"] = false
default["sentry"]["init.d"] = {
  "pidfile" => "/var/run/sentry.pid",
  "script" => "/etc/init.d/sentry"
}
default["sentry"]["gunicorn"] = true

default["sentry"]["nginx"] = {
  "domain" => "localhost",
  "ip_address" => "0.0.0.0",
  "port" => 80,
  "ip_as_server_name" => false
}

default["sentry"]["supervisor"] = "sentry_base"
default["sentry"]["servers"] = [{
                                  "name" => "sentry-1",
                                  "host" => "0.0.0.0",
                                  "port" => 9000
                                }]



default["sentry"]["settings"]["redis"]["hosts"] = {
  "0" => {
    "HOST" => "127.0.0.1",
    "PORT" => 6379
  }}


default["sentry"]["settings"]["tsdb"] = 'sentry.tsdb.redis.RedisTSDB'
default["sentry"]["settings"]["use_buffers"] = false
default["sentry"]["cleanup"]["on"] = true
default["sentry"]["cleanup"]["days"] = 30
default["sentry"]["cleanup"]["time"] = {
  "hour" => "*/12",
  "minute" => "10"
}
