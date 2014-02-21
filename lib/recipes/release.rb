require 'yaml'
require 'chromatic'

namespace :release do

  # retrieving the artifacts we want to deploy
  # use as:
  # before 'deploy:update', 'release:fetch'
  task :fetch do
    release.fetch_github_release
  end

  task :fetch_github_release do
    config = YAML.load_file('../../config/secrets.yml')

    GithubReleaseFetcher.init user_name: config['github']['username'],
                              auth_token: config['github']['token']
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
    selected_release.fetch_assets(repository_absolute_path).each { |artifact|
      logger.important %Q|- '#{artifact}'|
    }
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
end
