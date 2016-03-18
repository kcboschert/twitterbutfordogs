require 'csv'
require 'twitter'

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
  config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
  config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
  config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
end

users = ARGV

unless users.any?
  puts "USAGE: ruby tweets.rb [USERNAME_1] [USERNAME_2] ..."
  exit
end

tweets = []
users.each do |user|
  puts "Getting tweets for #{user}"
  user_tweets = client.user_timeline(user, :count => 200)
  tweets += user_tweets
  oldest = user_tweets.last.id-1

  while user_tweets.any?
    user_tweets = client.user_timeline(user, :count => 200, :max_id => oldest)
    break unless user_tweets.any?
    tweets += user_tweets
    oldest = user_tweets.last.id-1
  end
end

dog_names = %w(
  hachiko
  scoobydoo
  scrappydoo
  lassie
  toto
  snoopy
  pluto
  rintintin
  eddie
  clifford
  santoslhalper
  marmaduke
  odie
  dug
  balto
)

tweet_texts = []
tweets.each do |tweet|
  tweet_text = tweet.text.gsub(/- /,"")
  tweet_text = tweet_text.gsub(/\b(RT|MT) .+/,"") #take out anything after RT or MT
  tweet_text = tweet_text.gsub(/(\#|(h\/t)|(http))\S+/, "") #Take out URLs, hashtags, hts, etc.
  tweet_text = tweet_text.gsub(/@\S+/,"@#{dog_names.sample}") #replace people names with dog names
  tweet_text = tweet_text.gsub(/(\n|\r)/,"") #take out new lines.
  tweet_text = tweet_text.gsub(/\"/, "") #take out quotes.
  # handle parentheses

  tweet_text = tweet_text.strip
  next if tweet_text == ""

  # add ending punctuation
  tweet_text += "." if (tweet_text =~ /([\.\!\?]$)/).nil?

  tweet_texts << tweet_text
end

File.write("assets/tweets/text.txt", tweet_texts.join("\n"))
