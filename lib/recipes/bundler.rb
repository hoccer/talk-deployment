namespace :bundler do

  # installs required gems
  # use as:
  # after 'deploy', 'bundler:bundle'

  task :bundle do
    puts 'bundling'
      run "cd #{current_path}; rvm use #{rvm_ruby_string}; bundle install"
  end
end
