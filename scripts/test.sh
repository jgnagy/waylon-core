#!/bin/sh

apt-get update && apt-get install -y libsodium-dev

gem install bundler -v '~> 2.3'
bundle install
bundle exec rake
