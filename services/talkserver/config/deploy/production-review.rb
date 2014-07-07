# PRODUCTION-specific deployment configuration
# please put general deployment config in config/deploy.rb

server '80.82.205.22', :app
set :service_name, "#{application}-review"
set :deploy_to, "/home/#{runner}/#{application}-review"
