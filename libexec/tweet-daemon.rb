# Change this file to be a wrapper around your daemon code.

# Do your post daemonization configuration here
# At minimum you need just the first line (without the block), or a lot
# of strange things might start happening...
DaemonKit::Application.running! do |config|
  # Trap signals with blocks or procs
  # config.trap( 'INT' ) do
  #   # do something clever
  # end
  # config.trap( 'TERM', Proc.new { puts 'Going down' } )
  twitterconfig = DaemonKit::Config.load('twitter')
  
  Twitter.configure do |config|
  	config.consumer_key       = twitterconfig[:consumer_key]
  	config.consumer_secret    = twitterconfig[:consumer_secret]
  	config.oauth_token        = twitterconfig[:oauth_token]
  	config.oauth_token_secret = twitterconfig[:oauth_token_secret]
  end

  dbconfig = DaemonKit::Config.load('database')
  DaemonKit.logger.info dbconfig[:database]  
end

# Sample loop to show process
loop do
  Circlog::opid = DaemonKit.arguments.options[:opid].to_i if Circlog::opid < DaemonKit.arguments.options[:opid].to_i
  
  DaemonKit.logger.info "I'm running with Opid #{Circlog::opid}"
  DaemonKit.logger.info Twitter.home_timeline.first.text  
  sleep 10
  feeds = Circlog::circlog_tweet_feed(Circlog::opid)
  feeds.each do |feed|
    Twitter.update(feed)
  end

  Circlog::opid += feeds.length  
end
