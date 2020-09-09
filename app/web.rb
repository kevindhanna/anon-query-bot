class Web < Sinatra::Base
  get '/' do
    erb :web
  end

  get '/redirect' do
    return if Bot&.instance && Bot.instance.client_started?

    begin
      log = Log.create
      log.getting_token

      web_client = Slack::Web::Client.new
      rc = web_client.oauth_access(
        client_id: configatron.slack.client_id,
        client_secret: configatron.slack.client_secret,
        code: params[:code]
      )

      token = rc['bot']['bot_access_token']

      storage = Storage.instance
      storage.token = token

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
end
