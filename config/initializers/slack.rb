Slack = Slack::Notifier.new ENV['slack_webhook_url']

Slack.username = ENV["name"]
#Slack.channel = "#events"
