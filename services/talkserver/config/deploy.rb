require 'rubygems'
require 'bundler/setup'

require 'railsless-deploy'
require 'capistrano/ext/multistage'

$LOAD_PATH.push File.expand_path('../../../lib', File.dirname(__FILE__))
require 'github_release_fetcher'

set :stages, %w(production staging appliance)

set :application, 'talkserver'

set :scm, :none
# We deploy the content of this directory!
set :repository, 'cache'
set :repository_absolute_path, File.join(File.expand_path('../', File.dirname(__FILE__)), repository)

set :deploy_via, :copy
# Keep the last 25 releases. Any older releases are deleted
set :keep_releases, 25

# Run the deployment as this user
set :user, 'deployment'
# The services are run as this user
set :runner, 'talk'
set :use_sudo, true

depend :remote, :command, 'java'
depend :remote, :command, 'pwgen'

# Where on the server is the service deployed
set :deploy_to, "/home/#{runner}/#{application}"

# The Github repository which contains our releases
set :github_repository, 'hoccer/hoccer-talk-spike'
# The name of the product. Has to coincide with the git tag name
set :product_name, application

# Latest release if nil, specified version otherwise
# Use from command line via `cap <stagename> deploy -s product_version=<your_version_string>`
# e.g. `cap appliance deploy -s product_version=1.0.0`
set :product_version, nil

# Directories that are shared between releases.
set :shared_children, %w(log config)

# feature to explicitely suppress restart, use: $ cap _stage_ deploy -s perform_restart=false
set :perform_restart, true

## Custom Recipe Hooks
# The deploy:setup behaves oddly historically - fix this
after 'deploy:setup', 'misc:fix_permissions'

# Trigger cleanup of old releases
after 'deploy', 'deploy:cleanup'

before 'deploy:update', 'release:fetch'
after 'deploy:create_symlink', 'release:restart_service'
