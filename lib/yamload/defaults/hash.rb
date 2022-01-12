require "facets/hash/deep_merge"

module Yamload
  module Defaults
    class Hash
      attr_reader :defaults

      def initialize(defaults = nil)
        self.defaults = defaults
      end

      def defaults=(defaults)
        unless defaults.is_a?(::Hash) || defaults.nil?
          fail ArgumentError, "#{defaults} is not a hash"
        end
        @defaults = defaults
      end

      def merge(hash)
        return hash if @defaults.nil?
        fail ArgumentError, "#{hash} is not a hash" unless hash.is_a?(::Hash)
        @defaults.deep_merge(hash)
      end
    end
  end
end
