# -*- coding: utf-8 -*-
#
# Cookbook Name:: sentry cookbook
# Recipe:: default
#
# :copyright: (c) 2012 - 2013 by Alexandr Lispython (alex@obout.ru).
# :license: BSD, see LICENSE for more details.
# :github: http://github.com/Lispython/sentry-cookbook
#

include_recipe "sentry::default"
include_recipe "sentry::user"

# Create sentry instance virtualenv and config
sentry_conf "sentry" do
  virtualenv_dir node["sentry"]["virtualenv"]
  user node["sentry"]["user"]
  group node["sentry"]["group"]
  settings node["sentry"]["settings"]
  superusers node["sentry"]["superusers"]
end

node["sentry"]["servers"].each() do |server|

  # Running sentry instance
  sentry_instance "sentry-#{server["port"]}" do
    virtualenv node["sentry"]["virtualenv"]
    user node["sentry"]["user"]
    group node["sentry"]["group"]
    pidfile "/var/run/sentry-#{server["port"]}.pid"
    config node["sentry"]["config"]
    host server["host"]
    port server["port"]
    workers server["workers"]
    gunicorn server["gunicorn"]
    provider server["supervisor"] || node["sentry"]["supervisor"]
  end
end
