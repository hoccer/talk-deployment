require 'rubygems'
require 'bundler/setup'

require 'railsless-deploy'
require 'capistrano/ext/multistage'

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

set :github_repository, 'https://github.com/hoccer/hoccer-talk-spike'
set :release_tag_prefix, %Q|#{application}-|
set :artifact_name_prefix, %Q|#{application}-|

set :shared_children, %w(log)

# Custom Recipe Hooks
after 'deploy:setup', 'misc:fix_permissions'
after 'deploy', 'deploy:cleanup'

task :fill_cache do
  run_locally 'mkdir -p cache'
  # TODO: Actually retrieve the artifact we want to deploy here
  # from github release based on additional variables (repo, version?, ...)
  run_locally 'touch cache/foo'
end
before 'deploy:update', 'fill_cache'
