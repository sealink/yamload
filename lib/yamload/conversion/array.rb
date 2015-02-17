module Yamload
  module Conversion
    class Array
      def initialize(array)
        fail ArgumentError, "#{array} is not an Array" unless array.is_a?(::Array)
        @array = array
      end

      def to_immutable
        convert_elements.freeze
      end

      private

      def convert_elements
        @array.map { |element| Object.new(element).to_immutable }
      end
    end
  end
end
