#!/bin/sh

gem install bundler -v '~> 2.3'
bundle install
bundle exec rake release
