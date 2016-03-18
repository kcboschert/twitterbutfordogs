require 'csv'
require 'twitter'

class TweetStealer
  DOG_NAMES = %w(
    hachiko
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
    scoobydoo
    scrappydoo
  )

  def initialize
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
      config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
      config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
      config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
    end
    @name_map = {}
    @available_dog_names = DOG_NAMES.dup
  end

  def run(users)
    tweets = fetch_user_tweets(users)

    users.each do |user|
      @name_map[user] = @available_dog_names.shift
    end

    tweet_texts = sanitize_tweets(tweets)

    File.write("assets/tweets/text.txt", tweet_texts.join("\n"))
  end

  def sanitize_tweets(tweets)
    tweet_texts = []
    tweets.each do |tweet|
      tweet_text = tweet.text.gsub(/- /,"")
      tweet_text.gsub!(/\b(RT|MT) .+/,"") #take out anything after RT or MT
      tweet_text.gsub!(/(\#|(h\/t)|(http))\S+/, "") #Take out URLs, hashtags, hts, etc.

      usernames = tweet_text.scan(/@\w+/).sort_by(&:length).reverse
      usernames.each do |username|
        dog_name = "@#{get_dog_name(username)}"
        tweet_text.gsub!(username, dog_name)
      end
      tweet_text.gsub!(/(\n|\r)/,"") #take out new lines.
      tweet_text.gsub!(/\"/, "") #take out quotes.
      # handle parentheses

      tweet_text = tweet_text.strip
      next if tweet_text == ""
      next if tweet_text.start_with?("♫")
      next if tweet_text.split(" ").size < 4

      # add ending punctuation
      tweet_text += "." if (tweet_text =~ /([\.\!\?]$)/).nil?

      tweet_texts << tweet_text
    end
    tweet_texts
  end

  def fetch_user_tweets(users)
    tweets = []

    users.each do |user|
      puts "Getting tweets for #{user}"
      user_tweets = @client.user_timeline(user, :count => 200)
      tweets += user_tweets
      oldest = user_tweets.last.id-1

      while user_tweets.any?
        user_tweets = @client.user_timeline(user, :count => 200, :max_id => oldest)
        break unless user_tweets.any?
        tweets += user_tweets
        oldest = user_tweets.last.id-1
      end
    end

    tweets
  end

  def get_dog_name(username)
    return @name_map[username] if @name_map[username]
    @available_dog_names = DOG_NAMES.dup if @available_dog_names.empty?
    @name_map[username] = @available_dog_names.delete(@available_dog_names.sample)
    @name_map[username]
  end
end


if $PROGRAM_NAME == __FILE__
  users = ARGV
  unless users.any?
    puts "USAGE: ruby tweets.rb [USERNAME_1] [USERNAME_2] ..."
    exit
  end

  tweet_reader = TweetStealer.new
  tweet_reader.run(users)
end
