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

# Create sentry instance virtualenv and config
sentry_conf "sentry" do
  virtualenv_dir node["sentry"]["virtualenv"]
  user node["sentry"]["user"]
  group node["sentry"]["group"]
  settings node["sentry"]["settings"]
end


# Running sentry instance
sentry_instance "sentry-1" do
  virtualenv node["sentry"]["virtualenv"]
  user node["sentry"]["user"]
  group node["sentry"]["group"]
  pidfile "/var/run/sentry-1.pid"
  config node["sentry"]["config"]
end
