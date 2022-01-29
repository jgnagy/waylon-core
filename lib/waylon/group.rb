# frozen_string_literal: true

module Waylon
  # The basic, built-in Group class. Relies on Redis for storage and is managed directly by Waylon.
  # @note This class can be subclassed for external authentication mechanisms per Sense
  class Group
    attr_reader :name

    # @param name [String,Symbol] The name of the group
    def initialize(name)
      @name = name.to_sym
    end

    # Add a user to the group
    # @param user [User] User to add
    # @return [Boolean]
    def add(user)
      return false if include?(user)

      users = members
      users << user.email.downcase
      storage.store(key, users)
      true
    end

    # Remove a user from the group
    # @param user [User] User to remove
    # @return [Boolean]
    def remove(user)
      return false unless include?(user)

      users = members
      users.delete(user.email.downcase)
      storage.store(key, users)
      true
    end

    # Waylon Users in this group
    # @return [Array<User>] The members of this Group
    def members
      # all actions on Group funnel through here, so always make sure the key exists first
      storage.store(key, []) unless storage.key?(key)

      storage.load(key).sort.uniq
    end

    alias to_a members

    # Checks if a user a member
    # @param user [User] User to look for
    # @return [Boolean]
    def include?(user)
      members.include?(user.email.downcase)
    end

    private

    # Provides access to the top-level storage singleton
    # @return [Waylon::Storage]
    def storage
      Waylon::Storage
    end

    # A quick way to find the config/storage key for this Group
    # @return [String]
    def key
      "groups.#{name}"
    end
  end
end
