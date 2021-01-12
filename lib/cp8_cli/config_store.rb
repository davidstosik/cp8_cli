require "yaml"

module Cp8Cli
  class ConfigStore
    FILE_PREFIX = File.join(ENV["HOME"], ".")

    def initialize(name)
      @name = name
    end

    def [](key)
      data[key]
    end

    def exist?
      File.exist?(path)
    end

    def move_to(new_name)
      File.rename(path, path_for(new_name))
      @name = new_name
    end

    def save(key, value)
      data[key] = value
      File.new(path, "w") unless exist?
      File.open(path, "w") { |f| f.write(data.to_yaml) }
      value
    end


    private

      attr_reader :name

      def path
        path_for(name)
      end

      def path_for(store_name)
        FILE_PREFIX + store_name
      end

      def data
        @_data ||= load_data
      end

      def load_data
        YAML.load File.read(path)
      rescue
        {}
      end
  end
end
