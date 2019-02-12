#!/usr/bin/env ruby
#

require 'json'
require 'date'
require 'oauth'
require 'atom'
require_relative './markup_tweet.rb'

CONSUMER_KEY    = '<Twitter Consumer API keys>'
CONSUMER_SECRET = '<Twitter Consumer API secret key>'
ACCESS_TOKEN    = '<Twitter Access token>'
ACCESS_SECRET   = '<Twitter Access token secret>'
USER_NAME       = '<Twitter ID>'
LIST_NAME       = '<List名>'
AUTHOR          = '<名前>'
LINK_URL        = "https://twitter.com/#{USER_NAME}/lists/#{LIST_NAME}"
ATOM_PATH       = '<HttpdのDocumentRootなど>/twitter_atom.xml'
LAST_ID_FILE    = '<適当なディレクトリー>/last_twitter_id'
REQUEST_TWEET_COUNT   = 200
MINMUM_RSS_FEED_COUNT = 10
MAXIMUM_RSS_ENTRY_COUNT = 100

FEED_DEFAULT_ATTR = {
  title: "Twitter #{USER_NAME}/#{LIST_NAME}",
  links: [Atom::Link.new(href: LINK_URL)],
  authors: [Atom::Person.new(name: AUTHOR)],
  id: LINK_URL
}

def get_last_twitter_id
  IO.read(LAST_ID_FILE).gsub("\n", "")
rescue
  nil
end

def put_last_twitter_id(twitter_id)
  open(LAST_ID_FILE, "w") {|io| io.write twitter_id}
end

def oauth_consumer
  OAuth::Consumer.new(
    CONSUMER_KEY,
    CONSUMER_SECRET,
    site: 'http://api.twitter.com'
  )
end

def timeline_of_my_list(last_twitter_id)
  url = "https://api.twitter.com/1.1/lists/statuses.json?slug=#{LIST_NAME}&owner_screen_name=#{USER_NAME}"
  url += "&count=#{REQUEST_TWEET_COUNT}"
  url += "&since_id=#{last_twitter_id}"  if last_twitter_id
  #puts url
  JSON.parse(OAuth::AccessToken.new(oauth_consumer, ACCESS_TOKEN, ACCESS_SECRET).get(url).body)
end


def make_content(timelines)
  content = ""
  timelines.each do |tweet|
    content << "<img src='#{tweet['user']['profile_image_url']}' width='16px' height='16px' /> "
    content << "#{DateTime.parse(tweet['created_at']).to_time.localtime.strftime("%m月%d日 %H:%M")} "
    content << "<a href='http://twitter.com/#{tweet['user']['screen_name']}/status/#{tweet['id']}'>@#{tweet['user']['screen_name']}</a> "
    content << "<br /> "
    content << "#{markup_tweet(tweet)} "
    content << "<br /><br />\n"
  end

  content
end

def make_entry_id(tweet)
  "http://twitter.com/#{USER_NAME}/lists/#{LIST_NAME}##{tweet['id']}"
end

def update_atom(content, entry_id)
  feed = Atom::Feed.load_feed(File.open(ATOM_PATH)) rescue Atom::Feed.new(FEED_DEFAULT_ATTR)
  feed.updated = Time.now.strftime("%FT%T%:z")

  entry = Atom::Entry.new do |e|
    e.updated = feed.updated
    e.title = feed.title + Time.now.strftime(" %m月%d日 %H:%M")
    e.links << Atom::Link.new(href: LINK_URL)
    e.content = Atom::Content::Html.new(content)
    e.id = entry_id
  end
  feed.entries = feed.entries[0, MAXIMUM_RSS_ENTRY_COUNT - 1]
  feed.entries.unshift(entry)

  File.open(ATOM_PATH, "w") {|f| f.write(feed.to_xml)}
end


def main
  timelines = timeline_of_my_list(get_last_twitter_id)
  puts timelines.size
  if timelines.size >= MINMUM_RSS_FEED_COUNT
    update_atom(make_content(timelines.reverse), make_entry_id(timelines.first))
    put_last_twitter_id(timelines.first['id'])
  end
end

main
