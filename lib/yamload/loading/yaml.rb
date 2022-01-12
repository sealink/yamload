require "facets/kernel/blank"
require "ice_nine"

module Yamload
  module Loading
    class Yaml
      def initialize(file, dir)
        @file = file
        @dir = dir
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
        source = erb_parsed_content
        content = if YAML.respond_to?(:unsafe_load)
          YAML.unsafe_load(source)
        else
          # rubocop:disable Security::YAMLLoad
          YAML.load(source)
          # rubocop:enable Security::YAMLLoad
        end
        fail IOError, "#{@file}.yml is blank" if content.blank?
        content
      end

      def erb_parsed_content
        raw_content = File.read(filepath, encoding: "bom|utf-8", mode: "r")
        ERB.new(raw_content).result(binding)
      end

      def filepath
        fail IOError, "No yml files directory specified" if @dir.nil?
        fail IOError, "#{@dir} is not a valid directory" unless File.directory?(@dir)
        File.join(@dir, "#{@file}.yml")
      end

      def secrets_client
        options = {}
        options[:endpoint] = ENV["AWS_SECRETS_MANAGER_ENDPOINT"] if ENV.has_key?("AWS_SECRETS_MANAGER_ENDPOINT")
        @secrets_client ||= Aws::SecretsManager::Client.new(options)
      end

      def get_secret(key)
        secrets_client.get_secret_value(secret_id: key).secret_string
      end

      def ssm_client
        options = {}
        options[:endpoint] = ENV["AWS_SSM_ENDPOINT"] if ENV.has_key?("AWS_SSM_ENDPOINT")
        @ssm_client ||= Aws::SSM::Client.new(options)
      end

      def get_parameter(key, encrypted: true)
        ssm_client.get_parameter(
          name: key,
          with_decryption: encrypted
        ).parameter.value
      rescue Aws::SSM::Errors::ParameterNotFound => e
        puts "Parameter #{key} not found"
        raise e
      end
    end
  end
end
