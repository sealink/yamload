require 'facets/object/dup'
require 'ice_nine'

module Yamload
  module Conversion
    class Object
      def initialize(object)
        @object = object.clone? ? object.clone : object
      end

      def to_immutable
        convert
      end

      private

      def convert
        case @object
        when ::Array
          Array.new(@object).to_immutable
        when ::Hash
          Hash.new(@object).to_immutable
        else
          IceNine.deep_freeze!(@object)
        end
      end
    end
  end
end
