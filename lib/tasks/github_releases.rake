$LOAD_PATH.push File.expand_path("..", File.dirname(__FILE__))

require 'yaml'
require "chromatic"
require "github_release_fetcher"

namespace :github_releases do

  SECRETS = YAML::load_file("config/secrets.yml")
  REPOSITORY_PATH = "hoccer/hoccer-talk-spike"
  PRODUCT_NAMES = ["filecache", "talkserver"]
  
  desc "list available releases"
  task :list do
    repo = get_repo
    
    # list releases per product
    repo.products.each do |product_name, product|
      puts ":: #{product_name.dup.bold} (with #{product.releases.size} releases)"
      latest_release = product.latest_release
      product.releases.each do |release|
        release_name = (release == latest_release) ? release.tag_name.bold : release.tag_name
        puts "    - #{release_name} (with #{release.assets.size} assets attached, deployable: #{release.deployable?})"
        release.assets.each do |asset|
          puts "        - #{asset.name} (state: #{asset.state})"
        end
      end
    end
  end

  desc "download all assets of the latest deployable releases"
  task :fetch_latest_releases do
    repo = get_repo
    
    repo.products.each do |product_name, product|
      latest_release_name = product.latest_release ? product.latest_release.tag_name : "No latest release found"
      puts ":: #{product_name}, latest deployable release: #{latest_release_name}".bold
      if product.latest_release
        path = File.join("tmp/", product_name)
        FileUtils.mkdir_p path
        product.latest_release.fetch_assets(path)
      end
    end
  end
  
  
  def get_repo
    GithubReleaseFetcher.init({ :user_name => SECRETS["github"]["username"],
                                :auth_token => SECRETS["github"]["token"] })
    return GithubReleaseFetcher::Repository.new REPOSITORY_PATH, PRODUCT_NAMES
  end
  
end