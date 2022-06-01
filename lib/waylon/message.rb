# frozen_string_literal: true

module Waylon
  # Abstract Message module
  # @abstract
  module Message
    # Message author (meant to be overwritten by mixing classes)
    def author
      nil
    end

    # Message body
    def body
      nil
    end

    # Message channel (meant to be overwritten by mixing classes)
    def channel
      nil
    end

    # Does the Message mention the bot (meant to be overwritten by mixing classes)
    def mentions_bot?
      nil
    end

    # Is the Message a private/direct Message?
    def private?
      false
    end

    def to_bot?
      # private? || mentions_bot?
      true
    end
  end
end
