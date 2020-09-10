# Anonymoose
This [Slack](https://slack.com/intl/en-gb/) bot takes direct messages and puts them in a specified public channel.

## Usage
### Set up the workspace App and Generate the slack credentials
Create an [app](https://api.slack.com/apps) for your workspace and note the API Token.
Create a channel called "#anonymoose-questions" or set your own channel using the instructions below.

### Install / Configure Redis
Redis is used to hold the oAuth token and last sent message to avoid duplication. Install and run locally or use your favourite cloud Redis.

### Configure the bot

#### Set environment variables:

`REDIS_URL = "<your redis url>"`
`SLACK_CLIENT_ID = "<your-app-client-id>"`
`SLACK_CLIENT_SECRET = "<your-app-client-SECRET>"`


#### Optional:
##### Channel Name
The bot will default to a channel called "#anonymoose-questions" - set this if you don't want to use the channel "#anonymoose-questions"

This is set without the *#* in the name.
i.e. "#MyChannel" becomes just "MyChannel"

`CHANNEL_NAME = "<your-channel-name>"`

##### DM Response
This sets the message sent in reply to the user. By default it will say "Thanks, I've submitted your question."

If you want to change the DM response sent to the user, set:

`DM_RESPONSE = "<your-dm-response>"`

##### Error Response
This sets the message sent to the user if something goes wrong. By default it will say "Sorry, something went wrong, please contact your administrator."

If you want to change the error response sent to the user, set:

`ERROR_RESPONSE = "<your-dm-response>"`

### Run the Bot

to run locally in dev/test execute:
`bundle exec puma -C puma.rb`

or host on your favourite PAAS

### Logging

the bot puts some basic logs into a slack_bot.log, but to keep it anonymous it only logs:
- stack traces
- the public channel ID of the channel you specify
- when invalid DMs occur
- when a DM is received
- when it does things like get an oAuth token or fetch one from storage
