# Anonymoose
This [Slack](https://slack.com/intl/en-gb/) bot takes direct messages and puts them in a specified public channel.

## Usage
### Set up the workspace App and Generate the slack api token
Create an [app](https://api.slack.com/apps) for your workspace and note the API Token

### Configure the bot

Set environment variables:

`API_TOKEN = "<your-api-token>"`</br>

Optional:
If you don't want to use the channel #anonymoose-questions

`CHANNEL_NAME = "#<your-channel-name>"`

This is what the bot responds with when DM'd

`DM_RESPONSE = "<your-dm-response>"`

