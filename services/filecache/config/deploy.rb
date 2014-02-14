require 'rubygems'
require 'bundler/setup'
require 'capistrano/ext/multistage'

set :stages, %w(production staging appliance)

set :application, 'filecache'

set :user, 'deployment'
set :runner, 'talk'
set :use_sudo, false

set :deploy_to, "/home/#{runner}/#{application}"
