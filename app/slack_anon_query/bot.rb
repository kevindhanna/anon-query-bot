REDIS = Redis.new(url: configatron.redis_url)
log = Logger.new(STDOUT)

Slack.configure do |config|
  config.token = configatron.slack_api_token
  raise 'Missing Slack API token!' unless config.token
end

$bot = Slack::RealTime::Client.new
log.info ("slackbot - initialize") {"Initializing..."}

$bot.on :message do |data|
  if data.channel && data.channel[0] == "D"
    log.info ("slackbot - DM recieved") {"DM recieved on channelid #{data.channel}, processing"}
    begin
      channelid = channelid =  $bot.channels.values.select{ |channel| channel.name == configatron.channel_name }[0].id
      log.info ("slackbot - set channelid") {"Set message output channel to #{channelid}"}
      last_message = REDIS.get('lm')
      log.info ("slackbot - check last message") { "Compaing to last sent message to minimise duplicate messages..." }
      if last_message != data.text && data.text != configatron.dm_response && data.text != configatron.error_response && data.text.length > 1
        log.info ("slackbot - post message") { "Posting message to channel - '#{data.text}'" }
        $bot.message(channel: channelid, text: data.text)
        REDIS.set('lm', data.text)
        REDIS.expire('lm', 30)
        log.info ("slackbot - inform user") { "Replying to user their DM channel"}
        $bot.message(channel: data.channel, text: configatron.dm_response)
      else
        log.info ("break conditions met, data.text was '#{data.text}' and last_message was '#{last_message}'")
      end
    rescue Exception => e
      puts e.message
      log.info ("slackbot - ERROR") { "#{e}" }
      $bot.message(channel: data.channel, text: configatron.error_response)
    end
  end
end
