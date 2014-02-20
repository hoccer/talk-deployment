require 'yaml'

# retrieving the artifacts we want to deploy
# use as:
# after 'deploy:update', 'release:fetch'
namespace :release do

  task :fetch do
    release.fetch_github_release
  end

  task :fetch_github_release do
    config = YAML::load_file('../../config/secrets.yml')

    GithubReleaseFetcher.init({ :user_name => config['github']['username'],
                                :auth_token => config['github']['token'] })
    repo = GithubReleaseFetcher::Repository.new github_repository, [product_name]

    repo.products.each do |product_name, product|
      latest_release = product.latest_release
      if latest_release
        puts "Found latest release with name '#{latest_release.tag_name}'. Attempting to downlaod..."
        base_dir = File.absolute_path(File.dirname(__FILE__).split('/lib/recipes')[0])
        path = File.join(base_dir, '/services/', product_name, 'cache')
        product.latest_release.fetch_assets(path)
      else
        puts 'No release with asset available that can be deployed.'
        # XXX abort deployment?!
      end
    end
  end
end
