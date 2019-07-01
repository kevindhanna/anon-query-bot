module SlackAnonQuery
  class Bot < SlackRubyBot::Bot
    match /.*/ do |client, data, _match|
      return unless direct_message?(data)
      begin
        webclient = Slack::Web::Client.new token: ENV["SLACK_API_TOKEN"]
        channelid = webclient.channels_info(channel: ENV["CHANNEL_NAME"])['channel']['id']
        client.typing(channel: data.channel)
        client.say(channel: channelid, text: data.text)
        client.say(channel: data.channel, text: ENV["DM_RESPONSE"]) 
      rescue => exception
        return client.say(channel: data.channel, text: "Sorry, something went wrong, please contact your administrator.")
      end
    end
  end
end