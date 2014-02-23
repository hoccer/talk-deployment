module GithubReleaseFetcher
  class Release
    EXECUTABLE_FILE_EXTENSION = '.jar'

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
      @tag_name.split('-').last
    end

    def deployable?
      return false if assets.empty?
      one_executable? && uploaded?
    end

    def uploaded?
      assets.all? { |asset| asset.state == 'uploaded' }
    end

    def one_executable?
      executables = assets.select { |asset|
        asset.name[/^.*#{EXECUTABLE_FILE_EXTENSION}$/]
      }
      return executables.first.name if executables.size == 1
      false
    end

    def assets
      resolve_assets unless @assets
      @assets
    end

    def fetch_assets(path)
      assets.map { |asset|
        download_url = %Q|https://api.github.com/repos/#{@product.repository.name}/releases/assets/#{asset.id}|
        # puts "<GithubReleaseFetcher::Release.fetch_assets> Downloading asset '#{asset.name}'"
        # puts "                                               from '#{download_url}'"
        # puts "                                               to '#{path}'"

        c = Curl::Easy.new download_url do |curl|
          curl.headers['Accept'] = 'application/octet-stream'
          # http://developer.github.com/v3/#user-agent-required
          curl.headers['User-Agent'] = 'octokit-capistrano V 1.0'
        end
        c.follow_location = true
        c.http_auth_types = :basic
        c.username = GithubReleaseFetcher.user_name
        c.password = GithubReleaseFetcher.auth_token

        c.perform
        file_path = File.join(path, asset.name)
        File.open(file_path, 'w+') { |file|
          file.write c.body_str
        }
        file_path
      }
    end

    private

    def resolve_assets
      @assets = @raw_assets.get.data
    end
  end
end
