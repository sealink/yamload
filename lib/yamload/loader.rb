require 'yaml'
require 'ice_nine'
require 'classy_hash'
require 'facets/hash/deep_merge'

module Yamload
  class Loader
    def initialize(file, dir = Yamload.dir)
      @file = file
      @dir  = dir
    end

    def exist?
      File.exist?(filepath)
    end

    # <b>DEPRECATED:</b> Please use <tt>content</tt> instead.
    def loaded_hash
      warn '[DEPRECATION] `loaded_hash` is deprecated.  Please use `content` instead.'
      content
    end

    def content
      @content ||= IceNine.deep_freeze(defaults.deep_merge(load))
    end

    def obj
      @immutable_obj ||= HashToImmutableObject.new(loaded_hash).call
    end

    def reload
      @content = @immutable_obj = nil
      content
    end

    attr_writer :schema

    def schema
      @schema ||= {}
    end

    attr_writer :defaults

    def defaults
      @defaults ||= {}
    end

    def valid?
      validate!
      true
    rescue SchemaError
      false
    end

    def validate!
      @error = nil
      ClassyHash.validate(content, schema)
    rescue RuntimeError => e
      @error = e.message
      raise SchemaError, @error
    end

    def error
      return nil if valid?
      @error
    end

    private

    def load
      fail IOError, "#{@file}.yml could not be found" unless exist?
      YAML.load_file(filepath).tap do |hash|
        fail IOError, "#{@file}.yml is invalid" unless hash.is_a? Hash
      end
    end

    def filepath
      fail IOError, 'No yml files directory specified' if @dir.nil?
      fail IOError, "#{@dir} is not a valid directory" unless File.directory?(@dir)
      File.join(@dir, "#{@file}.yml")
    end
  end

  class SchemaError < StandardError; end
end
