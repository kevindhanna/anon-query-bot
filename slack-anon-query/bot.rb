module SlackAnonQuery
  class Bot < SlackRubyBot::Bot
    last_message = ""
    match /.*/ do |client, data, _match|
      return unless direct_message?(data)
      # work around for heroku sleep causing double posts
      return unless data.text != last_message
      begin
        webclient = Slack::Web::Client.new token: ENV["SLACK_API_TOKEN"]
        if ENV["CHANNEL_NAME"].nil?
          channelid = webclient.channels_info(channel: "#anonymoose-questions")['channel']['id']
        else
          channelid = webclient.channels_info(channel: ENV["CHANNEL_NAME"])['channel']['id']       
        end
        client.typing(channel: data.channel)
        client.say(channel: channelid, text: data.text)
        last_message = data.text
        if ENV["DM_RESPONSE"].nil?
          client.say(channel: data.channel, text: "Thanks, I've submitted your question.")
        else
          client.say(channel: data.channel, text: ENV["DM_RESPONSE"]) 
        end
      rescue Exception => e
        puts e.message
        return client.say(channel: data.channel, text: "Sorry, something went wrong, please contact your administrator.")
      end
    end
  end
end