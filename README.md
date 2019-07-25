# Anonymoose
This [Slack](https://slack.com/intl/en-gb/) bot takes direct messages and puts them in a specified public channel.

## Usage
### Set up the workspace App and Generate the slack api token
Create an [app](https://api.slack.com/apps) for your workspace and note the API Token.
Create a channel called "#anonymoose-questions" or set your own channel using the instructions below.

### Install / Configure Redis
Redis is used to hold the last sent message to avoid duplication (not 100% working). Install and run locally or use your favourite cloud Redis.

### Configure the bot

#### Set environment variables:

`REDIS_URL = "<your redis url>"`
`SLACK_API_TOKEN = "<your-api-token>"`


#### Optional:
##### Channel Name
The bot will default to a channel called "#anonymoose-questions" - set this if you don't want to use the channel "#anonymoose-questions"

This is set without the *#* in the name.
i.e. "#MyChannel" becomes just "MyChannel"

`CHANNEL_NAME = "#<your-channel-name>"`

##### DM Response
This sets the message sent in reply to the user. By default it will say "Thanks, I've submitted your question."

If you want to change the DM response sent to the user, set:

`DM_RESPONSE = "<your-dm-response>"`

### Run the Bot

to run locally in dev/test execute:
`rackup`

or host on your favourite PAAS

### Known Issues:

On Heroku free tier the bot will sometimes post more than once in response to a DM.
