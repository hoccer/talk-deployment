namespace :upstart do
  # use as:
  # after 'deploy:create_symlink', 'upstart:restart_service'
  desc %Q|restarts the service (#{service_name.light_blue})|
  task :restart_service do
    if perform_restart
      logger.important %Q|Restarting the service '#{service_name}' ...|
      run "sudo service #{service_name} restart"
    else
      logger.important %Q|As requested service '#{service_name}' is NOT restarted.|
    end
  end
end
