require 'rubygems'
require 'bundler/setup'

require 'railsless-deploy'
require 'capistrano/ext/multistage'

$LOAD_PATH.push File.expand_path('../../../lib', File.dirname(__FILE__))
require 'github_release_fetcher'

set :stages, %w(production staging appliance)

set :application, 'filecache'

set :scm, :none
set :repository, 'cache'
set :repository_absolute_path, File.join(File.expand_path('../', File.dirname(__FILE__)), repository)

set :deploy_via, :copy
set :keep_releases, 5

set :user, 'deployment'
set :runner, 'talk'
set :use_sudo, true

set :deploy_to, "/home/#{runner}/#{application}"

set :github_repository, 'hoccer/hoccer-talk-spike'
set :product_name, application

# Latest release if nil, specified version otherwise
# Use from command line via `cap <stagename> deploy -s product_version=<your_version_string>`
# e.g. `cap appliance deploy -s product_version=1.0.0`
set :product_version, nil

set :shared_children, %w(log)

# Custom Recipe Hooks
after 'deploy:setup', 'misc:fix_permissions'
after 'deploy', 'deploy:cleanup'

before 'deploy:update', 'release:clean_cache'
after 'release:clean_cache', 'release:fetch'
