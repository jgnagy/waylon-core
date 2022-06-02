#!/bin/sh

gem install bundler -v '~> 2.3'
bundle install
git status
bundle exec rake release
