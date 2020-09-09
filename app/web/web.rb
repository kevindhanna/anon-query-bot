require 'sinatra/base'

class Web < Sinatra::Base
  get '/' do
    erb :web
  end

  get '/redirect' do
    return if Bot.instance && Bot.instance.client_started?

    begin
      log = Log.create
      log.getting_token

      web_client = Slack::Web::Client.new
      rc = web_client.oauth_access(
        client_id: ENV['SLACK_CLIENT_ID'],
        client_secret: ENV['SLACK_CLIENT_SECRET'],
        code: params[:code]
      )

      token = rc['bot']['bot_access_token']

      storage = Storage.instance
      storage.set_token(token)

      Slack.configure do |config|
        config.token = storage.get_token
      end

      client = Slack::RealTime::Client.new
      Bot.create(client, storage, log)
      log.success
    rescue StandardError => e
      log = Log.create
      log.something_went_wrong(e)
    end
  end
end
