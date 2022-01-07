# frozen_string_literal: true

module Waylon
  # Abstract User module
  # @abstract
  module User
    # Extends the base class when included
    def self.included(base)
      base.extend ClassMethods
    end

    include Comparable

    # Class-level methods to be added to User subclasses
    module ClassMethods
      # This should be overridden by subclasses to provide a mechanism for looking up Users
      def find_by_handle(_email)
        raise NotImplementedError, "find_by_handle isn't implemented"
      end

      # Provides a simple mechanism for referencing User subclass's Sense
      # @return [Class] A Sense subclass
      def sense
        Sense
      end

      # This should be overridden by subclasses to provide a mechanism for the bot to get its own User
      def whoami
        raise NotImplementedError, "whoami isn't implemented"
      end
    end

    def initialize(id)
      @id = id
    end

    def <=>(other)
      id <=> other.id
    end

    # Meant to provide the User's email
    def email
      nil
    end

    # Meant to provide the User's handle
    def handle
      nil
    end

    # Meant to provide the User's id from the underlying Sense platform
    def id
      @id
    end

    # Meant to determine if the User's is "real" per the Sense platform
    def valid?
      true
    end
  end
end
