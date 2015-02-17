module Yamload
  module Validation
    class Result
      attr_reader :error

      def initialize(valid, error = nil)
        @valid = valid
        @error = error
      end

      def valid?
        @valid
      end
    end
  end
end
