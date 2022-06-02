#!/bin/sh

gem install bundler -v '~> 2.3'
bundle install
git diff
bundle exec rake release
