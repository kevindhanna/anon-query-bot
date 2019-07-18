# Anonymoose
This [Slack](https://slack.com/intl/en-gb/) bot takes direct messages and puts them in a specified public channel.

## Usage
### Set up the workspace App and Generate the slack api token
Create an [app](https://api.slack.com/apps) for your workspace and note the API Token

### Configure the bot

#### Set environment variables:

`SLACK_API_TOKEN = "<your-api-token>"`


#### Optional:

If you don't want to use the channel #anonymoose-questions

`CHANNEL_NAME = "#<your-channel-name>"`

If you want to change the DM response sent to the user:

`DM_RESPONSE = "<your-dm-response>"`

to run locally in dev/test execute:
`foreman start`

or host on your favourite PAAS

### Known Issues:

On Heroku free tier the bot will sometimes post more than once in response to a DM.
