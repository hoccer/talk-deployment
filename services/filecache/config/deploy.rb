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
set :deploy_via, :copy
set :keep_releases, 5

set :user, 'deployment'
set :runner, 'talk'
set :use_sudo, true

set :deploy_to, "/home/#{runner}/#{application}"

set :github_repository, 'hoccer/hoccer-talk-spike'
set :product_name, application

set :shared_children, %w(log)

# Custom Recipe Hooks
after 'deploy:setup', 'misc:fix_permissions'
after 'deploy', 'deploy:cleanup'
after 'deploy:update', 'release:fetch'
