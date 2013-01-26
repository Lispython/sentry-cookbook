action :init do
  Chef::Log.info("Make instance via supervisor #{new_resource.name}")

  supervisor_service new_resource.name do
    directory new_resource.virtualenv
    command "#{new_resource.virtualenv}/bin/sentry --config=#{new_resource.config} run_gunicorn -b #{new_resource.host}:#{new_resource.port} -w #{new_resource.workers}"
    environment "DJANGO_CONF" => new_resource.config
    user new_resource.user
    action :start
  end
end
