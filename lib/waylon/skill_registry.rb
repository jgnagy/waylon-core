# frozen_string_literal: true

module Waylon
  # A place to track all skills known to this instance of Waylon
  class SkillRegistry
    include Singleton

    # A wrapper around the singleton #register method
    # @param name [String] The name of the skill in the registry
    # @param class_name [Class] The class to associate with the name
    # @param condition [Condition] Criteria for whether or not the given subclass applies
    # @return [Route] The created Route instance
    def self.register(name, class_name, condition)
      instance.register(name, class_name, condition)
    end

    def default_route
      Routes::Default.new
    end

    # Gathers a Hash of help data for all routes a user is permitted to access
    # @param user [User] The user asking for help
    # @return [Hash]
    def help(user)
      data = {}
      @routes.select { |r| r.permits?(user) }.each do |permitted|
        data[permitted.destination.config_namespace] ||= []
        data[permitted.destination.config_namespace] << { name: permitted.name, help: permitted.help } if permitted.help
      end

      data.reject { |_k, v| v.empty? }
    end

    # Simple pass-through for logging through the Waylon Logger
    # @param [String] message The message to log
    # @param [String,Symbol] level The log level for this message
    def log(message, level = :info)
      ::Waylon::Logger.log(message, level)
    end

    # Add the provided Skill subclass to the registry under `name`
    # @param name [String] The name of the component in the registry
    # @param skill_class [Class] The class to associate with the name
    # @param condition [Condition] Criteria for whether or not the given subclass applies
    # @return [Route] The created Route instance
    def register(name, skill_class, condition)
      raise Exceptions::ValidationError, "Must be a kind of Skill" unless skill_class.ancestors.include?(Skill)

      @routes ||= []
      @routes << Route.new(name: name.to_s, destination: skill_class, condition: condition)
    end

    # Given a message, find a suitable skill Route for it (sorted by priority, highest first)
    # @param message [Waylon::Message] A Message instance
    # @return [Hash]
    def route(message)
      route = nil
      message_text = message.text.strip
      @routes ||= []
      @routes.sort_by(&:priority).reverse.each do |candidate_route|
        if candidate_route.permits?(message.author) && candidate_route.matches?(message_text)
          route = candidate_route
        elsif candidate_route.matches?(message_text)
          route = Routes::PermissionDenied.new
        end
        if route
          log("Using route '#{route.name}' based on '#{message_text}' from '#{message.author.email}'", :debug)
          break
        end
      end
      route
    end
  end
end
