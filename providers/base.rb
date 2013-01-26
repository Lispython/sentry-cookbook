action :init do
  Chef::Log.info("Make instance via base #{new_resource.name}")

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

  # Start webservice
  # sentry --config=/etc/sentry.conf.py start
  service new_resource.name do
    supports :status => true, :restart => true, :reload => true
  end

  template init_script do
      mode 0700
      source "init.erb"
      variables(:user => new_resource.user,
                :group => new_resource.group,
                :pidfile => new_resource.pidfile,
                :spawner => spawner,
                :name => new_resource.name)
      notifies :restart, "service[#{new_resource.name}]"
    end
end
