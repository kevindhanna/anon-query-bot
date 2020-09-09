$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'redis'
require 'slack-ruby-client'
require 'logger'
require 'config/config'
require 'app/slack_anon_query/bot'
require 'app/web/web'

$stdout.sync = true

unless ENV['RACK_ENV'] == 'production'
  require 'dotenv'
  Dotenv.load
end

storage = Storage.create
log = Log.create
if storage.get_token
  begin
    log.using_stored_token

    Slack.configure do |config|
      config.token = storage.get_token
    end

    client = Slack::RealTime::Client.new
    Bot.create(client, storage, log)
    log.success
  rescue
    log = Log.create
    log.something_went_wrong(e)
  end
end

run Web
