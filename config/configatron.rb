require 'configatron'
unless ENV['RACK_ENV'] == 'production'
  require 'dotenv'
  Dotenv.load
end


configatron.slack_api_token = ENV['SLACK_API_TOKEN']
configatron.redis_url = ENV['REDIS_URL']
configatron.dm_response = ENV['DM_RESPONSE'] || "Thanks, I've submitted your question."
configatron.channel_name = ENV['CHANNEL_NAME'] || "anonymoose-questions"
configatron.error_response = ENV['ERROR_RESPONSE'] || "Sorry, something went wrong, please contact your administrator."

