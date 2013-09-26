# -*- coding: utf-8 -*-
#
# Cookbook Name:: sentry cookbook
# Resource:: instance

# Create sentry instance
#
# :copyright: (c) 2012 - 2013 by Alexandr Lispython (alex@obout.ru).
# :license: BSD, see LICENSE for more details.
# :github: http://github.com/Lispython/sentry-cookbook
#

actions :init

attribute :name, :kind_of => String, :name_attribute => true
attribute :user, :kind_of => String
attribute :group, :kind_of => String
attribute :virtualenv, :kind_of => String
attribute :pidfile, :kind_of => String
attribute :variables, :kind_of => Hash
attribute :config, :kind_of => String
attribute :host, :kind_of => String, :default => "0.0.0.0"
attribute :port, :kind_of => Integer, :default => 9000
attribute :gunicorn, :kind_of => [FalseClass, TrueClass], :default => true
attribute :workers, :kind_of => Integer, :default => 3
attribute :log_folder, :kind_of => String


def initialize(*args)
  super
  @action = :init
  @sub_resources = []
  @provider = Chef::Provider::SentryBase
end
