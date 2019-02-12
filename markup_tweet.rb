
def markup_tweet(tweet)
  text = tweet['text'].gsub("\n", "")
  entities = tweet['entities']
  MarkupTweet::markup_media(text, entities)
  MarkupTweet::markup_urls(text, entities)
  MarkupTweet::markup_user_mentions(text, entities)
  MarkupTweet::markup_hashtags(text, entities)
  text
end

# this module only call from Kernel#markup_tweet
module MarkupTweet
  # see https://dev.twitter.com/docs/tweet-entities
  def self.markup_media(text, entities)
    return text unless entities['media']
    entities['media'].each do |image|
      text << "<div><a href='#{image['display_url']}'><img src='#{image['media_url']}' /></a></div>"
    end
    text
  end

  def self.markup_urls(text, entities)
    entities['urls'].each do |url|
      new_url = url['expanded_url'] || url['url']
      text.gsub!(url['url'], "<a href='#{new_url}'>#{new_url}</a>")
    end
    text
  end

  def self.markup_user_mentions(text, entities)
    entities['user_mentions'].each do |mention|
      screen_name = mention['screen_name']
      text.gsub!("@#{screen_name}", "<a href='http://twitter.com/#{screen_name}'>@#{screen_name}</a>")
    end
    text
  end


  def self.markup_hashtags(text, entities)
    entities['hashtags'].each do |hashtag|
      hash_text = hashtag['text']
      text.gsub!(/[\#＃♯]#{Regexp.quote hash_text}/, "<a href='http://twitter.com/search?q=%23#{hash_text}'>##{hash_text}</a>")
    end
    text
  end
end

