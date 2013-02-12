action :init do
  Chef::Log.info("Make instance via monit #{new_resource.name}")

  config = new_resource.config || node["sentry"]["config"]

  spawner = "#{ new_resource.virtualenv }/bin/#{ new_resource.name }-spawner"
  init_script = "/etc/init.d/#{ new_resource.name }"

  template spawner do
    mode 0777
    owner new_resource.user
    group new_resource.group
    source "spawner.erb"
    variables(:virtualenv => new_resource.virtualenv,
              :config => new_resource.config,
              :port => new_resource.port,
              :host => new_resource.host,
              :workers => new_resource.workers || node["sentry"]["web"]["options"]["workers"],
              :gunicorn => new_resource.gunicorn || node["sentry"]["gunicorn"])
  end

  template init_script do
      mode 0700
      source "init.erb"
      variables(:user => new_resource.user,
                :group => new_resource.group,
                :pidfile => new_resource.pidfile,
                :spawner => spawner,
                :name => new_resource.name)
  end

  service new_resource.name do
    supports :start => true, :restart => true, :stop => true
    provider Chef::Provider::MonitMonit
  end

  monit_conf "#{new_resource.name}" do
    template "sentry-monit.erb"
    config(:start_command => "#{init_script} start",
           :stop_command => "#{init_script} stop",
           :host => new_resource.host,
           :port => new_resource.port,
           :name => new_resource.name,
           :pidfile => new_resource.pidfile)
    cookbook "sentry"
    notifies :restart, resources(:service => new_resource.name), :delayed
  end

end
