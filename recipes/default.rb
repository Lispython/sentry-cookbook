# -*- coding: utf-8 -*-
#
# Cookbook Name:: sentry cookbook
# Recipe:: default
#
# :copyright: (c) 2012 by Alexandr Lispython (alex@obout.ru).
# :license: BSD, see LICENSE for more details.
# :github: http://github.com/Lispython/sentry-cookbook
#

group node["sentry"]["group"] do
  action :create
  system true
  not_if "grep #{node['sentry']['group']} /etc/group"
end

user node["sentry"]["user"] do
  comment "sentry service user"
  gid node["sentry"]["group"]
  system true
  shell "/bin/bash"
  action :create
  not_if "grep #{node['sentry']['user']} /etc/passwd"
end


directory node["sentry"]["virtualenv"] do
  owner node["sentry"]["user"]
  group node["sentry"]["group"]
  mode 0777
  recursive true
  action :create
end

python_virtualenv node["sentry"]["virtualenv"] do
  owner node["sentry"]["user"]
  group node["sentry"]["group"]
  action :create
end

# Intstall sentry version
python_pip "sentry" do
  user node["sentry"]["user"]
  group node["sentry"]["group"]
  provider Chef::Provider::PythonPip
  virtualenv node["sentry"]["virtualenv"]
  version node["sentry"]["version"]
  action :install
end

template node["sentry"]["config"] do
  owner node["sentry"]["user"]
  group node["sentry"]["group"]
  source "sentry.conf.erb"
end

# Install third party plugins

node["sentry"]["3_party_plugins"].each do |item|
  python_pip item["pypi_name"] do
    user node["sentry"]["user"]
    group node["sentry"]["group"]
    provider Chef::Provider::PythonPip
    virtualenv node["sentry"]["virtualenv"]
    if item.has_key?("version")
      version item["version"]
    end
    action :install
  end
end

bash "chown virtualenv" do
  code <<-EOH
  chown -R #{node['sentry']['user']}:#{node['sentry']['group']} #{node['sentry']['virtualenv'] }
  EOH
end

# Run migrations
# sentry --config=/etc/sentry.conf.py upgrade
bash "upgrade sentry" do
  user node["sentry"]["user"]
  group node["sentry"]["group"]
  code <<-EOH
  . #{node['sentry']['virtualenv']}/bin/activate &&
  #{node['sentry']['virtualenv']}/bin/python #{node['sentry']['virtualenv']}/bin/sentry --config=#{node['sentry']['config']} upgrade --noinput &&
  deactivate
  EOH
end


# Create superusers
template node["sentry"]["superuser_creator_script"] do
  owner node["sentry"]["user"]
  group node["sentry"]["group"]
  source "superuser_creator.py.erb"
end

# sentry --config=/etc/sentry.conf.py createsuperuser

bash "create sentry superusers" do
  user node["sentry"]["user"]
  group node["sentry"]["group"]

  code <<-EOH
  . #{node['sentry']['virtualenv']}/bin/activate &&
  #{node['sentry']['virtualenv']}/bin/python #{node['sentry']['superuser_creator_script']} &&
  deactivate
  EOH
end

file node['sentry']['superuser_creator_script'] do
  action :delete
end

template node["sentry"]["spawner"] do
  mode 0777
  owner node["sentry"]["user"]
  group node["sentry"]["group"]
  source "spawner.erb"
end

if node['sentry']['start']
  # bash "start sentry server" do
  #   user node["sentry"]["user"]
  #   group node["sentry"]["group"]
  #   code <<-EOH
  #   . #{node['sentry']['virtualenv']}/bin/activate &&
  #   #{node['sentry']['virtualenv']}/bin/python #{node['sentry']['virtualenv']}/bin/sentry --config=#{node['sentry']['config']} start &
  #   deactivate
  #   EOH
  # end


  # Start webservice
  # sentry --config=/etc/sentry.conf.py start
  service "sentry" do
    supports :status => true, :restart => true, :reload => true
  end

  template node["sentry"]["init.d"]["script"] do
    mode 0700
    source "init.erb"
    user node["sentry"]["user"]
    group node["sentry"]["group"]
    notifies :start, "service[sentry]"
  end
end
