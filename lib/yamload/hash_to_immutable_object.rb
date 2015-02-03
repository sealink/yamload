require 'facets/hash/rekey'
require 'anima'

module Yamload
  class HashToImmutableObject
    def initialize(hash)
      @hash = hash.rekey
    end

    def call
      anima = Anima.new(*@hash.keys)
      Class.new { include anima }.new(
        @hash.map.with_object({}) { |(key, value), hash|
          hash[key] = convert(value)
        }
      )
    end

    private

    def convert(value)
      if value.is_a?(Hash)
        self.class.new(value).call
      elsif value.is_a?(Array)
        value.map { |element| convert(element) }
      else
        value
      end
    end
  end
end
