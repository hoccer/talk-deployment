namespace :bundler do

  # installs required gems
  # use as:
  # after 'deploy', 'bundler:bundle'
  # or before 'upstart:restart_service', 'bundler:bundle'
  task :bundle do
    puts 'bundling'
    run "cd #{current_path}; rvm use #{rvm_ruby_string}; bundle install"
  end
end
