require 'rubygems'
require 'bundler/setup'

require 'railsless-deploy'
require 'capistrano/ext/multistage'

require 'rvm/capistrano'

set :rvm_ruby_string, 'ruby-2.0.0-p353@riemann-metrics'
set :rvm_autolibs_flag, 'read-only'
set :rvm_type, :system
set :rvm_install_type, :stable

set :stages, %w(production staging appliance)

set :application, 'riemann-metrics'

set :scm, :git
set :repository, 'git@github.com:hoccer/riemann-metrics.git'

set :deploy_via, :copy
set :keep_releases, 5

# Run the deployment as this user
set :user, 'deployment'
# The services are run as this user
set :runner, 'riemann'
set :use_sudo, true

# Where on the server is the service deployed
set :deploy_to, "/home/#{runner}/#{application}"

# Directories that are shared between releases.
set :shared_children, %w(log)

# feature to explicitely suppress restart, use: $ cap _stage_ deploy -s perform_restart=false
set :perform_restart, true

#########################
## Custom Recipe Hooks ##
#########################

# Trigger cleanup of old releases
after 'deploy', 'deploy:cleanup'

set :service_name, application
after 'deploy:create_symlink', 'upstart:restart_service'
before 'upstart:restart_service', 'bundler:bundle'

before 'deploy:setup', 'rvm:install_ruby' # install Ruby and create gemset
# before 'deploy:setup', 'rvm:create_gemset' # only create gemset
# The deploy:setup behaves oddly historically - fix this
after 'deploy:setup', 'misc:fix_permissions'
