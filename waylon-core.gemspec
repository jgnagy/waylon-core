# frozen_string_literal: true

require_relative "lib/waylon/version"

Gem::Specification.new do |spec|
  spec.name          = "waylon-core"
  spec.version       = Waylon::Core::VERSION
  spec.authors       = ["Jonathan Gnagy"]
  spec.email         = ["jonathan@therubyist.org"]

  spec.summary       = "Core library for the Waylon bot framework"
  spec.description   = "The core components of the Waylon bot framework for Ruby"
  spec.homepage      = "https://github.com/jgnagy/waylon-core"
  spec.license       = "MIT"
  spec.required_ruby_version = "~> 3.2"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/jgnagy/waylon-core"
  spec.metadata["changelog_uri"] = "https://github.com/jgnagy/waylon-core/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "addressable", "~> 2.8"
  spec.add_dependency "faraday", "~> 1.10"
  spec.add_dependency "i18n", "~> 1.8"
  spec.add_dependency "json", "~> 2.6"
  spec.add_dependency "moneta", "~> 1.4"
  spec.add_dependency "puma", "~> 6.4"
  spec.add_dependency "rbnacl", "~> 7.1"
  spec.add_dependency "resque", "~> 2.2"

  spec.add_development_dependency "bundler", "~> 2.4"
  spec.add_development_dependency "pry", "~> 0.14"
  spec.add_development_dependency "rake", "~> 13.1"
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "rubocop", "~> 1.57"
  spec.add_development_dependency "rubocop-rake", "~> 0.6"
  spec.add_development_dependency "rubocop-rspec", "~> 2.25"
  spec.add_development_dependency "simplecov", "~> 0.22"
  spec.add_development_dependency "yard", "~> 0.9", ">= 0.9.27"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
