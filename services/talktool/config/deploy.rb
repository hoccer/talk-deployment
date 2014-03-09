require 'rubygems'
require 'bundler/setup'

require 'railsless-deploy'
require 'capistrano/ext/multistage'

$LOAD_PATH.push File.expand_path('../../../lib', File.dirname(__FILE__))

set :stages, %w(staging)

set :application, 'talktool'

set :scm, :none
# We deploy the content of this directory!
set :repository, 'files'
set :repository_absolute_path, File.join(File.expand_path('../', File.dirname(__FILE__)), repository)
set :jar_path, "#{repository_absolute_path}/jar"

set :deploy_via, :copy
set :copy_remote_dir, "/tmp"
# Keep the last 25 releases. Any older releases are deleted
set :keep_releases, 25

# Run the deployment as this user
set :user, 'administrator' # should be 'deployment'
# The services are run as this user
set :runner, 'administrator' # should be 'talk'

set :use_sudo, false
default_run_options[:pty] = true

depend :remote, :command, "java"

# Where on the server is the service deployed
set :deploy_to, "/home/#{runner}/#{application}"

# Directories that are shared between releases.
set :shared_children, %w(log config)

# explicitely specify artifact path, 
# use: $ cap <stagename> deploy -s artifact_path=<path_to_artifact>
set :artifact_path, nil

## Custom Recipe Hooks
# The deploy:setup behaves oddly historically - fix this
# after 'deploy:setup', 'misc:fix_permissions'

# after deploying the app master, symlink all the slaves to its assets
after 'deploy:create_symlink', 'scaling:create_symlinks'

# Trigger cleanup of old releases
after 'deploy', 'deploy:cleanup'

# copy the relevant jar to our 'repository'
before 'deploy:update', 'scaling:get_artifact'


####################
### custom tasks ###
####################

namespace :scaling do # TODO: find a better namespace name
  task :get_artifact do
    remove_old_jars
    copy_jar
    link_executable
  end
  
  task :copy_jar do
    run_locally "cp #{artifact_path} #{jar_path}"
  end
  
  task :remove_old_jars do
    run_locally "rm -rf #{jar_path}"
    run_locally "mkdir -p #{jar_path}"
  end
  
  task :link_executable do
    run_locally %Q|cd #{jar_path}; ln -s #{File.basename(artifact_path)} #{application}.jar|
  end

  task :create_symlinks, :roles => :slave do
    commands = []
    slave_current = "~/#{application}/current"
    slave_shared = "~/#{application}/shared"
   
    commands << "rm -rf #{slave_current}"
    commands << "mkdir #{slave_current}"
    commands << "cd #{current_path};for file in *;do if [ ! -L $file ];then ln -s #{current_path}/$file #{slave_current}/$file;fi;done"
    shared_children.map do |dir|
      d = dir.shellescape
      commands << "rm -rf -- #{slave_current}/#{d}"
      commands << "ln -s -- #{slave_shared}/#{dir.split('/').last.shellescape} #{slave_current}/#{d}"
    end
    run commands.join(' && ') if commands.any?
  end
end
