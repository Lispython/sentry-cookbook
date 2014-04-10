# -*- coding: utf-8 -*-
#
# Cookbook Name:: sentry cookbook
# Recipe:: user
#
# :copyright: (c) 2012 - 2013 by Alexandr Lispython (alex@obout.ru).
# :license: BSD, see LICENSE for more details.
# :github: http://github.com/Lispython/sentry-cookbook
#

group node["sentry"]["group"] do
  action :create
  system true
  not_if "grep #{node['sentry']['group']} /etc/group"
end

user node["sentry"]["user"] do

  if node["sentry"]["userhome"]
    home node["sentry"]["userhome"]
  end

  comment "sentry service user"
  gid node["sentry"]["group"]
  system true
  shell "/bin/bash"
  action :create
  not_if "grep #{node['sentry']['user']} /etc/passwd"
end
