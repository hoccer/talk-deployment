module GithubReleaseFetcher

  class Release
    attr_reader :tag_name

    def self.construct_from_raw_release(raw_release, product)
      new(raw_release.tag_name, raw_release.rels[:assets], product)
    end

    def initialize(tag_name, raw_assets, product)
      @tag_name = tag_name
      @raw_assets = raw_assets # id, name, state
      @product = product
      @assets = nil
    end

    def version
      @tag_name.split("-").last
    end

    def deployable?
      return false if assets.empty?
      assets.all? { |asset| asset.state == "uploaded" }
    end

    def assets
      resolve_assets unless @assets
      @assets
    end

    def fetch_assets path
      assets.each do |asset|
        download_url = %Q|https://api.github.com/repos/#{@product.repository.name}/releases/assets/#{asset.id}| # XXX make path Constant
        puts " - #{asset.name} download_url: #{download_url}"
      end
    end

    private

      def resolve_assets
        @assets = @raw_assets.get.data
      end

  end
end
