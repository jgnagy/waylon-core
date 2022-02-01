# Waylon::Core

Waylon is a bot framework in the same vein as [Lita](https://www.lita.io/) built to make creating bots easy and fun. It supports swappable sensory inputs (chat platforms, web endpoints, and more), easy to build Skills, built-in and extensible permissions, and modern JSON logging.

This repo/library is the core of Waylon; it provides the essential pieces of the framework and some working examples.

## Why Waylon

Waylon is built to be scalable and to deliver features missing in other chat frameworks. For instance, it supports self-reporting and discovering plugin features (such as supporting HTML cards, reactions, etc.) to making Skills more powerful and dynamic. Waylon also supports a full, shared caching layer to make scaling simple. It also makes heavy use of Redis for queuing work, meaning zero-downtime upgrades and faster user responses.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'waylon-core'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install waylon-core

If you're building a plugin for Waylon, you'll only need to require the core:

```ruby
require "waylon/core"
```

If you're launching your own bot, require the entire library and plus any additional plugins:

```ruby
require "waylon"
```

## Usage

### Demo Mode

Alone, this library isn't super useful for running a bot, but it does include a "demo", local REPL mode for experimenting. To use it, run `rake demo`.

## Development

Waylon's development pipeline makes heavy use of [RSpec](https://rspec.info/) for testing (and [SimpleCov](https://github.com/simplecov-ruby/simplecov) for reporting on coverage), [Rubocop](https://rubocop.org/) for linting/format checking, [YARD](https://yardoc.org/) for documentation, and [RoxanneCI](https://github.com/apps/roxanneci) for CI. Most of this is built-in and will work out-of-the-box for GitHub PRs.

To get started locally, after checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rake` to run the tests and linting. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jgnagy/waylon-core.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
