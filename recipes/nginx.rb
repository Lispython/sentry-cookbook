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

Chef::Log.info("Making nginx frontend for sentry service")


template "#{node[:nginx][:dir]}/sites-available/sentry.conf" do
  source 'nginx.conf.erb'
  owner user
  group user
  variables(:domain => node["multiqa"]["domain"],
            :project_name => node["multiqa"]["project_name"],
            :site_name => node["multiqa"]["site_name"],
            :media_root => node["multiqa"]["media_root"],
            :static_root => node["multiqa"]["static_root"],
            :server_ip => node["multiqa"]["server_ip"],
            :current => node["multiqa"]["current"])

  notifies :reload, resources(:service => "nginx")
end

nginx_site "sentry.conf"
