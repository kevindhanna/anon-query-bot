unless ENV['RACK_ENV'] == 'production'
  require 'dotenv'
  Dotenv.load
end

configatron.bot.channel_name = ENV['CHANNEL_NAME'] || 'anonymoose-questions'
configatron.bot.dm_response = ENV['DM_RESPONSE'] || 'Thanks, I’ve submitted your question.'
configatron.bot.error_response = ENV['ERROR_RESPONSE'] || 'Sorry, something went wrong, please contact your administrator.'
configatron.slack.client_id = ENV['SLACK_CLIENT_ID']
configatron.slack.client_secret = ENV['SLACK_CLIENT_SECRET']
configatron.redis.url = ENV['REDIS_URL']

raise "Slack Client ID is required" unless configatron.slack.client_id
raise "Slack Client Secret is Required" unless configatron.slack.client_secret
raise "Redis URL is required" unless configatron.redis.url
