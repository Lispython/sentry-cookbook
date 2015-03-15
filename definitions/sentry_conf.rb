# -*- coding: utf-8 -*-
#
# Cookbook Name:: sentry cookbook
# Definition:: sentry_conf
#
# Making sentry configuration file
#
# :copyright: (c) 2012 - 2013 by Alexandr Lispython (alex@obout.ru).
# :license: BSD, see LICENSE for more details.
# :github: http://github.com/Lispython/sentry-cookbook
#

class Chef::Recipe
  include Chef::Mixin::DeepMerge
end

define :sentry_conf,
       :name => nil,
       :template => "sentry/sentry.conf.erb",
       :virtualenv => nil,
       :user => "sentry",
       :group => "sentry",
       :config => nil,
       :superusers => [],
       :variables => {},
       :templates_cookbook => "sentry",
       :settings => {} do

  Chef::Log.info("Making sentry config for: #{params[:name]}")
  include_recipe "python::virtualenv"
  include_recipe "python::pip"
  include_recipe "sentry::default"

  virtualenv_dir = params[:virtualenv] || node["sentry"]["virtualenv"]
  #settings_variables = Chef::Mixin::DeepMerge.deep_merge!(node[:sentry][:settings].to_hash, params[:settings])
  node.default["settings_variables"] = params[:settings]

  config = params[:config] || node["sentry"]["config"]
  node.default["settings_variables"]["config"] = config

  if node["sentry"]["use_queue"]
    node.set["settings_variables"]["use_queue"] = true
  end

  Chef::Log.info("Making directory for virtualenv: #{virtualenv_dir}")
  # Making application virtualenv directory
  directory virtualenv_dir do
    owner params[:user]
    group params[:group]
    mode 0777
    recursive true
    action :create
  end

  Chef::Log.info("Making virtualenv: #{virtualenv_dir}")
  # Creating virtualenv structure
  python_virtualenv virtualenv_dir do
    owner params[:user]
    group params[:group]
    action :create
  end

  Chef::Log.info("Making config #{config}")
  # Creating sentry config
  template config do
    owner params[:user]
    group params[:group]
    source params[:template]
    mode 0777
    variables(node["settings_variables"].to_hash)
    cookbook params[:templates_cookbook]
  end

  # Intstall sentry via pip
  Chef::Log.info("Install sentry version #{node["sentry"]["version"]}")
  python_pip "sentry" do
    provider Chef::Provider::PythonPip
    user params[:user]
    group params[:group]
    virtualenv virtualenv_dir
    version node["sentry"]["version"]
    action :install
  end

  # Install database drivers
  node['sentry']['settings']['databases'].each do |key, db_options|
    driver_name = nil
    if db_options['ENGINE'] == 'django.db.backends.postgresql_psycopg2'
      driver_name = 'psycopg2'
    elsif db_options['ENGINE'] == 'django.db.backends.mysql'
      if node['platform'] == 'ubuntu'
        package "libmysqlclient-dev" # mysql-python requires this package to be installed
        driver_name = 'mysql-python'
      else
        driver_name = 'MySQLdb'
      end
    elsif db_options['ENGINE'] == 'django.db.backends.oracle'
      driver_name = 'cx_Oracle'
    elsif db_options['ENGINE'] == 'django.db.backends.sqlite3'  # default handler
      driver_name = 'pysqlite'
    else
      raise "You need specify database ENGINE"
    end

    if driver_name
      Chef::Log.info("Install #{driver_name} driver")
      python_pip driver_name do
        user params[:user]
        group params[:group]
        provider Chef::Provider::PythonPip
        virtualenv virtualenv_dir
        action :install
      end
    end
  end

  # # Install third party plugins
  node["sentry"]["settings"]["third_party_plugins"].each do |item|
    python_pip item["pypi_name"] do
      user params[:user]
      group params[:group]
      provider Chef::Provider::PythonPip
      virtualenv virtualenv_dir
      if item.has_key?("version")
        version item["version"]
      end
      action :install
    end
  end


  bash "chown virtualenv" do
    code <<-EOH
  chown -R #{params['user']}:#{params['group']} #{virtualenv_dir}
  EOH
  end

  # # Run migrations
  # # sentry --config=/etc/sentry.conf.py upgrade
  bash "upgrade sentry" do
    user params[:user]
    group params[:group]
    code <<-EOH
  . #{virtualenv_dir}/bin/activate &&
  #{virtualenv_dir}/bin/python #{virtualenv_dir}/bin/sentry --config=#{config} upgrade --noinput &&
  deactivate
  EOH
  end


  if node['sentry']['cleanup']['on']
    Chef::Log.info("Making sentry config for cleanup #{node['sentry']['cleanup']['days']}")

    cron_d "cleanup" do
      hour node["sentry"]["cleanup"]["time"]["hour"]
      minute node["sentry"]["cleanup"]["time"]["minute"]
      day node["sentry"]["cleanup"]["time"]["day"]
      month node["sentry"]["cleanup"]["time"]["month"]
      weekday node["sentry"]["cleanup"]["time"]["weekday"]
      user params[:user]

      command ". #{virtualenv_dir}/bin/activate && #{virtualenv_dir}/bin/python #{virtualenv_dir}/bin/sentry --config=#{config} cleanup --days=#{node['sentry']['cleanup']['days']} && deactivate"
    end
  end

  # # Create superusers
  template node["sentry"]["superuser_creator_script"] do
    owner params[:user]
    group params[:group]

    source "sentry/superuser_creator.py.erb"
    variables(:config => config,
              :superusers => params[:superusers] || node["sentry"]["superusers"],
              :virtualenv => virtualenv_dir)
    cookbook params[:templates_cookbook]
  end

  # # sentry --config=/etc/sentry.conf.py createsuperuser
  bash "create sentry superusers" do
    user params[:user]
    group params[:group]

    code <<-EOH
  . #{virtualenv_dir}/bin/activate &&
  #{virtualenv_dir}/bin/python #{node['sentry']['superuser_creator_script']} &&
  deactivate
  EOH
  end

  file node['sentry']['superuser_creator_script'] do
    action :delete
  end

end
