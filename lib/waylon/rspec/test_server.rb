# frozen_string_literal: true

require "rspec"
require "rspec/expectations"
require "rspec/mocks"

major, *_unused = RSpec::Core::Version::STRING.split(/\./)
abort "RSpec 3 or greater required" if major.to_i < 3

require "waylon/core"
require "waylon/skills/default"
require "waylon/rspec/skill"
require "waylon/rspec/test_channel"
require "waylon/rspec/test_message"
require "waylon/rspec/test_sense"
require "waylon/rspec/test_user"
require "waylon/rspec/test_worker"

config = Waylon::Config.instance
config.load_env

Waylon::Cache.storage = Moneta.new(:Cookie)
Waylon::Logger.log("Found Global Admins: #{config.admins}")

Waylon::RSpec::TestUser.find_or_create(
  name: "Waylon Smithers",
  email: "waylon.smithers@example.com"
)

# This is the user for test chats
if ENV["USER_EMAIL"]
  Waylon::RSpec::TestUser.find_or_create(
    name: "Home Simpson",
    email: ENV["USER_EMAIL"]
  )
else
  Waylon::RSpec::TestUser.find_or_create(name: "Homer Simpson")
end

Waylon::RSpec::TestChannel.find_or_create("random")

# Load demo skills here
require "waylon/skills/diagnostics"
require "waylon/skills/fun"
require "waylon/skills/groups"
require "waylon/skills/help"

# Handle demo chat REPL
def adminuser
  @adminuser ||= Waylon::RSpec::TestUser.find_or_create(name: "Charles Montgomery Burns", handle: "monty")
  Waylon::Group.new("admins").add(@adminuser)
  @adminuser
end

def chatroom
  @chatroom ||= Waylon::RSpec::TestChannel.new(0)
end

def handle_exit_input
  if @admin_enabled
    puts "Switching back to a normal user."
    @admin_enabled = false
  else
    puts "Talk to you later!"
    exit
  end
end

def msg_details(body, from, privately)
  details = {
    user_id: from.id,
    text: body,
    created_at: Time.now
  }
  if privately
    details[:type] = :private
    details[:receiver_id] = robot.id
  else
    details[:type] = :channel
    details[:channel_id] = channel ? channel.id : chatroom.id
  end
  details
end

def robot
  @robot ||= Waylon::RSpec::TestUser.new(0)
end

def testuser
  @testuser ||= Waylon::RSpec::TestUser.new(1)
end

def this_user
  @admin_enabled ? adminuser : testuser
end

def handle_input(body, from: this_user, privately: true)
  if %w[bye exit leave quit].include?(body)
    handle_exit_input
  elsif ["su", "su -", "su admin", "su - admin"].include?(body)
    puts 'Admin enabled! Use "exit" to go back to a normal user.'
    @admin_enabled = true
  elsif @admin_enabled && %w[irb pry].include?(body)
    pry
  else
    message_count = Waylon::RSpec::TestSense.sent_messages.size

    Waylon::RSpec::TestSense.perform(msg_details(body, from, privately))
    Waylon::RSpec::TestWorker.handle(Waylon::RSpec::TestSense.fake_queue)
    result = Waylon::RSpec::TestSense.sent_messages[message_count..].join("\n")
    puts("(@#{Waylon::RSpec::TestUser.whoami.handle}) >> #{result}")
  end
end

# A lambda for a test chat server
repl = lambda do |prompt|
  print prompt
  handle_input($stdin.gets.chomp!)
end

loop do
  @admin_enabled ||= false
  repl["(@#{this_user.handle}) << "]
end
