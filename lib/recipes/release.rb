require 'yaml'
require 'chromatic'

namespace :release do

  # retrieving the artifacts we want to deploy
  # use as:
  # before 'deploy:update', 'release:fetch'
  task :fetch do
    release.clean_cache
    if adhoc_artifact_path
      logger.info %Q|Performing a adhoc release fetch...|.colorize( :black ).on_white
      release.fetch_adhoc_artifact
    else
      logger.info %Q|Performing a github release fetch...|.colorize( :black ).on_white
      release.load_secrets
      release.fetch_github_release
    end
    release.link_executable_asset
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

  task :fetch_adhoc_artifact do
    if File.exists? adhoc_artifact_path
      logger.info %Q|Fetching #{adhoc_artifact_path.inspect}...|
      run_locally %Q|cp #{adhoc_artifact_path} #{repository_absolute_path}|
      set :executable_artifact, adhoc_artifact_path
      logger.important %Q|Executable artifact is: '#{executable_artifact}'|

      release.set_adhoc_product_version
      release.create_version_info
    else
      logger.important %Q|Adhoc artifact at #{adhoc_artifact_path.inspect} cannot be found. ABORTING|
      exit
    end
  end

  task :set_adhoc_product_version do
    artifact_git_revision = `cd #{File.dirname(executable_artifact)}; git rev-parse HEAD`.strip!
    dirty_repo_files = `cd #{File.dirname(executable_artifact)}; git status -s --untracked-files=no | wc -l`.strip!
    branch_name = `cd #{File.dirname(executable_artifact)}; git rev-parse --abbrev-ref HEAD`.strip!
    if Integer(dirty_repo_files) == 0
      set :product_version, %Q|adhoc_#{branch_name}_#{artifact_git_revision}|
    else
      set :product_version, %Q|adhoc_#{branch_name}_#{artifact_git_revision}_with_#{dirty_repo_files}_dirty_files|
    end
    logger.important product_version
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
