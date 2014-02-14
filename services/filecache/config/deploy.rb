require 'rubygems'
require 'bundler/setup'
require 'capistrano/ext/multistage'

set :stages, %w(production staging appliance)

set :application, "filecache"
