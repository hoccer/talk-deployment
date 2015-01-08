# PRODUCTION-specific deployment configuration
# please put general deployment config in config/deploy.rb

server 'talkserver.talk.hoccer.de', :app
set :service_name, "#{application}-review"
set :deploy_to, "/home/#{runner}/#{application}-review"
