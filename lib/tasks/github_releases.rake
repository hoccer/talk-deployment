$LOAD_PATH.push File.expand_path('..', File.dirname(__FILE__))

require 'yaml'
require 'chromatic'
require 'github_release_fetcher'

namespace :github_releases do

  SECRETS = YAML.load_file('config/secrets.yml')
  REPOSITORY_PATH = 'hoccer/hoccer-talk-spike'
  PRODUCT_NAMES = %w{filecache talkserver test}

  desc 'lists only latest release that would be deployed'
  task :latest do
    repo = init_repo

    # list latest deployable release per product
    repo.products.each do |product_name, product|
      puts "* #{product_name.dup.cyan.bold} (#{product.releases.size} release(s))"
      latest_release = product.latest_release
      if latest_release
        puts "    * #{latest_release.tag_name.green.bold} (#{latest_release.version.cyan}) (#{latest_release.assets.size} asset(s) attached, deployable: #{latest_release.deployable? ? 'Yes'.green : 'No'.red})"
        latest_release.assets.each do |asset|
          puts "        * #{asset.name.magenta}#{"*".magenta.bold if latest_release.one_executable? == asset.name} (state: #{asset.state})"
        end
      else
        puts 'No latest deployable release available!'.red.bold
      end
    end
  end

  desc 'lists all available releases'
  task :list do
    repo = init_repo

    # list releases per product
    repo.products.each do |product_name, product|
      puts "* #{product_name.dup.cyan.bold}:"
      latest_release = product.latest_release
      product.releases.each do |release|
        release_name = (release == latest_release) ? release.tag_name.green.bold : release.tag_name
        puts "    * #{release_name} (#{release.version.cyan}) (#{release.assets.size} asset(s) attached, deployable: #{release.deployable? ? 'Yes'.green : 'No'.red})"
        release.assets.each do |asset|
          puts "        * #{asset.name.magenta}#{"*".magenta.bold if release.one_executable? == asset.name} (state: #{asset.state})"
        end
      end
    end
  end

  desc 'downloads all assets of the latest deployable releases'
  task :fetch_latest_releases do
    repo = init_repo

    repo.products.each do |product_name, product|
      latest_release_name = product.latest_release ? product.latest_release.tag_name : 'No latest release found'
      puts "* #{product_name.dup.cyan.bold}:"
      puts "  * latest deployable release: #{latest_release_name.green.bold} (#{product.latest_release.version.cyan})"
      if product.latest_release
        path = File.join('tmp/', product_name)
        FileUtils.mkdir_p path
        product.latest_release.fetch_assets(path).each { |asset_path|
          puts "    * Saved asset to '#{asset_path.magenta.bold}'"
        }
      end
    end
  end

  def init_repo
    GithubReleaseFetcher.init user_name: SECRETS['github']['username'],
                              auth_token: SECRETS['github']['token']
    GithubReleaseFetcher::Repository.new REPOSITORY_PATH, PRODUCT_NAMES
  end

end
