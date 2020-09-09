$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'configatron'
require 'logger'
require 'redis'
require 'sinatra/base'
require 'slack-ruby-client'
require 'app/config'
require 'app/bot'
require 'app/web'

$stdout.sync = true

storage = Storage.create
log = Log.create
if storage.token
  begin
    log.using_stored_token

    Slack.configure do |config|
      config.token = storage.token
    end

    client = Slack::RealTime::Client.new
    Bot.create(client, storage, log)
    log.success
  rescue StandardError => e
    log = Log.create
    log.something_went_wrong(e)
  end
end

run Web
