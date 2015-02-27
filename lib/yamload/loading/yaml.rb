require 'facets/kernel/blank'
require 'ice_nine'

module Yamload
  module Loading
    class Yaml
      def initialize(file, dir)
        @file = file
        @dir  = dir
      end

      def exist?
        File.exist?(filepath)
      end

      def content
        @content ||= IceNine.deep_freeze(load)
      end

      def reload
        @content = @immutable_obj = nil
        content
      end

      private

      def load
        fail IOError, "#{@file}.yml could not be found" unless exist?
        YAML.load(erb_parsed_content).tap do |content|
          fail IOError, "#{@file}.yml is blank" if content.blank?
        end
      end

      def erb_parsed_content
        raw_content = File.read(filepath, encoding: 'bom|utf-8', mode: 'r')
        ERB.new(raw_content).result
      end

      def filepath
        fail IOError, 'No yml files directory specified' if @dir.nil?
        fail IOError, "#{@dir} is not a valid directory" unless File.directory?(@dir)
        File.join(@dir, "#{@file}.yml")
      end
    end
  end
end
