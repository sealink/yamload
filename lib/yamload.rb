require 'yamload/version'

module Yamload
  class << self
    attr_accessor :dir
  end
end

require 'yamload/loader'
require 'yamload/hash_to_immutable_object'
