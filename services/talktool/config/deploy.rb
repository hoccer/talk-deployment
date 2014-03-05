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
after 'deploy:setup', 'misc:fix_permissions'

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
  end
  
  task :copy_jar do
    absolute_artifact_path = File.join(File.expand_path('../', File.dirname(__FILE__)), artifact_path)
    #logger.info %Q| absolute artifact_path is '#{absolute_artifact_path}'|
    run_locally "cp #{absolute_artifact_path} #{jar_path}"
  end
  
  task :remove_old_jars do
    run_locally "rm -rf #{jar_path}"
    run_locally "mkdir -p #{jar_path}"
  end
end
