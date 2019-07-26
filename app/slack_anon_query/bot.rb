REDIS = Redis.new(url: ENV["REDIS_URL"])
log = Logger.new(STDOUT)

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
  raise 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
end

$bot = Slack::RealTime::Client.new
log.info ("slackbot - initialize") {"Initializing..."}

$bot.on :message do |data|
  if data.channel && data.channel[0] == "D"
    log.info ("slackbot - DM recieved") {"DM recieved on channelid #{data.channel}, processing"}
    begin
      if ENV["CHANNEL_NAME"].nil?
        channelid =  $bot.channels.values.select{ |channel| channel.name == "anonymoose-questions" }[0].id
      else
        channelid =  $bot.channels.values.select{ |channel| channel.name == ENV["CHANNEL_NAME"] }[0].id
      end
      log.info ("slackbot - set channelid") {"Set message output channel to #{channelid}"}
      last_message = REDIS.get('lm')
      log.info ("slackbot - check last message") { "Compaing to last sent message to minimise duplicate messages..." }
      if last_message != data.text && data.text != ENV[DM_RESPONSE] && data.text != "Sorry, something went wrong, please contact your administrator."
        log.info ("slackbot - post message") { "Posting message to channel - '#{data.text}'" }
        $bot.message(channel: channelid, text: data.text)
        REDIS.set('lm', data.text)
        REDIS.expire('lm', 30)
        log.info ("slackbot - inform user") { "Replying to user their DM channel"}
        if ENV["DM_RESPONSE"].nil?
          $bot.message(channel: data.channel, text: "Thanks, I've submitted your question.")
        else
          $bot.message(channel: data.channel, text: ENV["DM_RESPONSE"]) 
        end
      end
    rescue Exception => e
      puts e.message
      log.info ("slackbot - ERROR") { "#{e}" }
      $bot.message(channel: data.channel, text: "Sorry, something went wrong, please contact your administrator.")
    end
  end
end
