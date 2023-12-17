# frozen_string_literal: true

module Waylon
  # A place to track all skills known to this instance of Waylon
  class SkillRegistry
    include Singleton

    attr_reader :routes

    # A wrapper around the singleton #register method
    # @param name [String] The name of the skill in the registry
    # @param class_name [Class] The class to associate with the name
    # @param condition [Condition] Criteria for whether or not the given subclass applies
    # @return [Route] The created Route instance
    def self.register(name, class_name, condition)
      instance.register(name, class_name, condition)
    end

    def self.find_by_name(name)
      [
        *instance.routes,
        Routes::PermissionDenied.new,
        Routes::BlackHole.new,
        Routes::Default.new
      ].find { |r| r.name == name.to_s }
    end

    def self.route(message)
      instance.route(message)
    end

    # Provides the default route based on the received message.
    # @param message [Waylon::Message] The received message
    # @return [Waylon::Route]
    def default_route(message)
      message.to_bot? ? Routes::Default.new : Routes::BlackHole.new
    end

    # Gathers a Hash of help data for all routes a user is permitted to access
    # @param user [User] The user asking for help
    # @return [Hash]
    def help(user)
      data = {}
      @routes.select { |r| r.permits?(user) && r.mention_only? }.each do |permitted|
        data[permitted.destination.component_namespace] ||= []
        data[permitted.destination.component_namespace] << if permitted.help
                                                             { name: permitted.name, help: permitted.help }
                                                           else
                                                             { name: permitted.name }
                                                           end
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
      @routes << Route.new(name: name.to_s, destination: skill_class, condition:)
    end

    # Given a message, find a suitable skill Route for it (sorted by priority, highest first)
    # @param message [Waylon::Message] A Message instance
    # @return [Hash]
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/PerceivedComplexity
    def route(message)
      route = nil
      message_text = message.body.strip
      @routes ||= []
      @routes.sort_by(&:priority).reverse.each do |this_route|
        if this_route.permits?(message.author) &&
           this_route.matches?(message_text) &&
           (this_route.properly_mentions?(message) || message.private?)
          route = this_route
        elsif this_route.permits?(message.author) &&
              this_route.matches?(message_text) &&
              !this_route.properly_mentions?(message)
          # Black hole these because they're not direct mentions
          route = Routes::BlackHole.new
        elsif this_route.matches?(message_text)
          route = Routes::PermissionDenied.new
        end
        if route
          log("Using route '#{route.name}' based on '#{message_text}' from '#{message.author.email}'", :debug)
          break
        end
      end
      route
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/PerceivedComplexity
  end
end
