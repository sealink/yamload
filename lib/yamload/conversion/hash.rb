require 'facets/hash/rekey'
require 'anima'

module Yamload
  module Conversion
    class Hash
      def initialize(hash)
        fail ArgumentError, "#{array} is not a Hash" unless hash.is_a?(::Hash)
        @hash = hash.rekey
      end

      def to_immutable
        immutable_objects_factory.new(converted_hash)
      end

      private

      def immutable_objects_factory
        anima = Anima.new(*@hash.keys)
        Class.new do
          include Adamantium
          include anima
        end
      end

      def converted_hash
        @hash.map.with_object({}) { |(key, value), hash|
          hash[key] = Object.new(value).to_immutable
        }
      end
    end
  end
end
