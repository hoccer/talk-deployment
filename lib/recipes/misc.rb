namespace :misc do
  # fixes annoying habit of capistrano to create root owned project directory
  # but without use_sudo we cannot create the project directory since
  # the runner and user are different.
  # use as:
  # after 'deploy:setup', 'misc:fix_permissions'
  task :fix_permissions do
    sudo %Q|
      chown -R #{runner}:#{user} #{deploy_to}
    |
  end
end
