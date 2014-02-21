module GithubReleaseFetcher
  class Repository
    attr_reader :products, :name

    def initialize(repository_name, product_names = [])
      @name = repository_name
      @products = {}
      fetch_releases product_names
    end

    def fetch_releases(product_names)
      fail 'Client not initialized' unless GithubReleaseFetcher.client
      releases = GithubReleaseFetcher.client.releases @name
      product_names.each do |product_name|
        @products[product_name] = filter_releases(product_name, releases)
      end
    end

    private

    def filter_releases(product_name, releases)
      relevant_releases = releases.select do |release|
        release.tag_name.downcase.start_with? product_name.downcase
      end
      Product.new product_name, relevant_releases, self
    end
  end
end
