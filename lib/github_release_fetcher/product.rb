module GithubReleaseFetcher
  class Product
    attr_reader :name, :releases, :repository

    def initialize(name, releases = [], repository)
      @name = name
      @releases = []
      @repository = repository
      releases.each do |release|
        @releases << Release.construct_from_raw_release(release, self)
      end
      @releases.sort! { |a, b| b.version <=> a.version }
    end

    def latest_release
      @releases.each do |release|
        return release if release.deployable?
      end
      nil
    end
  end
end
