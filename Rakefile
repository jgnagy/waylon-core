# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"
require "redis/errors"
require "resque/tasks"
require "yard"
require "waylon/core"

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new
YARD::Rake::YardocTask.new do |y|
  y.options = [
    "--markup", "markdown"
  ]
end

task default: %i[spec rubocop yard]

task :demo do
  require "waylon/rspec/test_server"
end
