# frozen_string_literal: true

module Waylon
  # Abstract Message module
  # @abstract
  module Message
    # Message author (meant to be overwritten by mixing classes)
    def author
      nil
    end

    # Message channel (meant to be overwritten by mixing classes)
    def channel
      nil
    end
  end
end
