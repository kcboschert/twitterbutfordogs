require_relative "../tweet_stealer.rb"

describe TweetStealer do
  class FakeTweet
    attr_accessor :text

    def initialize(text)
      @text = text
    end
  end

  describe "sanitize_tweets" do
    it "replaces usernames with dog names" do
      usernames = (1..(TweetStealer::DOG_NAMES.size + 1)).map do |dog_num|
        "@person#{dog_num}"
      end
      person_name_tweet = [FakeTweet.new(usernames.join(" and "))]

      result = subject.sanitize_tweets(person_name_tweet)

      TweetStealer::DOG_NAMES.each do |dog_name|
        expect(result.first).to include("@#{dog_name}")
      end
    end
  end
end
