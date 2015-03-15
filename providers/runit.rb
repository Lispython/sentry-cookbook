action :init do
  Chef::Log.info("Make instance via runit #{new_resource.name}")

  sentry_new_resource = new_resource

  log_folder = sentry_new_resource.log_folder || "/var/log/runit/#{sentry_new_resource.name}/"

  runit_service sentry_new_resource.name do
    template_name "sentry"
    log_template_name "sentry"
    action [:enable, :restart]
    options(:user => sentry_new_resource.user,
            :group => sentry_new_resource.group,
            :service_name => sentry_new_resource.name,
            :config => sentry_new_resource.config,
            :pidfile => sentry_new_resource.pidfile,
            :port => sentry_new_resource.port,
            :host => sentry_new_resource.host,
            :virtualenv => sentry_new_resource.virtualenv,
            :log_folder => log_folder)
  end


end
