#!/usr/bin/env ruby
require 'octokit'
require 'curb'

if ARGV.size != 2
  puts 'Username and auth-token required.'
  puts './ocokit.rb [username] [auth-token]'
  puts "See: 'https://help.github.com/articles/creating-an-access-token-for-command-line-use'"
  exit
end

user_name = ARGV[0]
auth_token = ARGV[1]
tag_prefix = 'filecache'
repository = 'hoccer/hoccer-talk-spike'

client = Octokit::Client.new access_token: auth_token
releases = client.releases repository

relevant_releases = releases.select do |release|
  release.tag_name.start_with? tag_prefix
end

# tag_name = relevant_releases.first.tag_name

asset_id = relevant_releases.first.rels[:assets].get.data.first.id

# curl -H "Accept:application/octet-stream" -u "#{user_name}:#{auth_token}" -L -o hoccer-talk-filecache-1.0.0-jar-with-dependencies.jar https://api.github.com/repos/hoccer/hoccer-talk-spike/releases/assets/77555

# https://api.github.com/repos/hoccer/hoccer-talk-spike/releases/assets/77555
download_url = %Q|https://api.github.com/repos/#{repository}/releases/assets/#{asset_id}|

puts download_url

c = Curl::Easy.new download_url do |curl|
  curl.headers['Accept'] = 'application/octet-stream'
  # http://developer.github.com/v3/#user-agent-required
  curl.headers['User-Agent'] = 'octokit-capistrano V 1.0'
end

c.follow_location = true
c.http_auth_types = :basic
c.username = user_name
c.password = auth_token

c.perform

puts c.body_str.size
