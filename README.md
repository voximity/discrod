# discrod

discrod is an experimental Discord library for Crystal. I am writing this to serve as a replacement
for one of my [bot projects'](https://engauge.zanderf.net/) current implementation in C#.

If you are looking for a production-ready Discord library, check out [discordcr](https://github.com/discordcr/discordcr).
This library is not ready for full use.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
    discrod:
        github: voximity/discrod
```

## Usage

```cr
require "discrod"

client = Discrod::Client.new token: "my-token", token_type: Discrod::TokenType::Bot

client.on_message_create do |message|
    if message.content == "ping"
        builder = Discrod::EmbedBuilder.new do |e|
            e.with_title "Pong!"
            e.with_description "discrod speaking!"
            e.with_current_time
            e.with_author(message.author)
        end

        message.react Discrod::Emoji.new ":confetti_ball:"
        message.channel.create_message embed: builder.build
    end
end

client.connect
```

All endpoints are available in `Client` as low-level API calls with very little abstraction between.
For higher-level API calls, each resource has their appropriate methods to help mitigate `Client` usage.
For example, `Message#delete` is synonymous with `Client#delete_message(channel_id, message_id)`.

### Caches

By default, resource caching is enabled. You can assign a cache to periodically wipe:

```cr
client.guild_cache!.clear_periodic 1.hour
```

## Contributing

1. Fork it (https://github.com/voximity/discrod/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
