$LOAD_PATH.push File.expand_path("..", File.dirname(__FILE__))

#puts __FILE__
#puts $LOAD_PATH

require "chromatic"
require "github_release_fetcher"

namespace :github_releases do
  
  #$ rake github_releases:list[kristinew,fc069cecf1cefc8d8cbbb6747b38cc20237ed356]
  desc "list available releases"
  task :list, :user, :token do |t, args| # arguments: user_name, auth_token
    puts "Args are: #{args}"
    
    repo = get_repo args[:user], args[:token]
    
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

  task :latest_release, :user, :token do |t, args|
    repo = get_repo args[:user], args[:token]
    
    repo.products.each do |product_name, product|
      latest_release_name = product.latest_release ? product.latest_release.tag_name : "No latest release found"
      puts " - #{product_name}, latest deployable release: #{latest_release_name}"
      #if product.latest_release
      #  product.latest_release.fetch_assets("tmp")
      #end
    end
  end
  
  
  def get_repo(user_name, token)
    GithubReleaseFetcher.init({ :user_name => user_name,
                                :auth_token => token }) # better get this from file
    return GithubReleaseFetcher::Repository.new "hoccer/hoccer-talk-spike", ["filecache", "talkserver", "lulu"]
  end
  
end