module GithubReleaseFetcher
  require 'octokit'

  require 'github_release_fetcher/repository'
  require 'github_release_fetcher/product'
  require 'github_release_fetcher/release'

  class << self
    attr_reader :user_name, :client

    def init(options = {})
      # TODO: validate input
      @user_name = options[:user_name]
      @client = Octokit::Client.new access_token: options[:auth_token]
    end

  end
end

