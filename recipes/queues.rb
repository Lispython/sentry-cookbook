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

node.set["sentry"]['use_queue'] = true

  # Create celery monitoring
runit_service "sentry-queue" do
  template_name "celery_worker"
  log_template_name "celery_worker"
  finish_script_template_name "celery_worker"
  finish true
  # control_template_names("d" => "celery_worker-control",
  #                        "h" => "celery_worker-control",
  #                        "q" => "celery_worker-control",
  #                        "k" => "celery_worker-control")

  # control ["d", "h", "q", "k"]

  options(:user => node["sentry"]["user"],
          :group => node["sentry"]["group"],
          :current => node["sentry"]["userhome"],
          :log_folder => "/var/log/celery/sentry/",
          :virtualenv => node["sentry"]["virtualenv"],
          :config => node["sentry"]["config"]
)
end
