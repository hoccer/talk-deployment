require 'yaml'
require 'chromatic'

namespace :release do

  # retrieving the artifacts we want to deploy
  # use as:
  # before 'deploy:update', 'release:fetch'
  task :fetch do
    release.load_secrets
    release.clean_cache
    release.fetch_github_release
    release.link_executable_asset
  end

  # restarts the service
  # use as:
  # after 'deploy:create_symlink', 'release:restart_service'
  task :restart_service do
    logger.important %Q|Restarting the service '#{product_name}'|
  end

  task :load_secrets do
    if File.exist?('../../config/secrets.yml')
      set :secrets, YAML.load_file('../../config/secrets.yml')
    else
      logger.important %Q|Please set your secrets. (config/secrets.yml). Consult the README for help!|
      exit
    end
  end

  task :fetch_github_release do
    GithubReleaseFetcher.init user_name: secrets['github']['username'],
                              auth_token: secrets['github']['token']
    repo = GithubReleaseFetcher::Repository.new github_repository, [product_name]

    # We only care about ONE product here
    product = repo.products[product_name]
    logger.important "Fetching artifacts for '#{product.name}'"

    if product_version
      logger.info %Q|Selecting release for specificed version: '#{product_version}'...|
      selected_release = product.release_by_version(product_version)
    else
      logger.info 'Selecting latest (deployable) release since no specific version was specified...'
      selected_release = product.latest_release
    end

    unless selected_release
      logger.important 'No deployable release acquired! ABORTING'
      exit
    end
    set :product_version, selected_release.version unless product_version

    logger.important "Selected release: #{product_version} ('#{selected_release.tag_name}')"
    logger.info "Downloading #{selected_release.assets.size} artifact(s)..."

    set :release_artifacts, selected_release.fetch_assets(repository_absolute_path)
    release_artifacts.each { |artifact|
      logger.important %Q|- '#{artifact}'|
    }
    set :executable_artifact, selected_release.one_executable?
    logger.important %Q|Executable artifact is: '#{executable_artifact}'|
    release.create_version_info
  end

  task :create_version_info do
    File.open(File.join(repository_absolute_path, 'version'), 'w+') { |file|
      file << product_version
    }
    logger.important "Wrote '#{product_version}' to file 'version'"
  end

  task :clean_cache do
    run_locally "rm -rf #{repository_absolute_path}"
    run_locally "mkdir -p #{repository_absolute_path}"
  end

  task :link_executable_asset do
    run_locally %Q|cd #{repository_absolute_path}; ln -s #{File.basename(executable_artifact)} #{product_name}.jar|
  end
end
