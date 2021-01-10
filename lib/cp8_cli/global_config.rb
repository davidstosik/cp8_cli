require "cp8_cli/config_store"

module Cp8Cli
  class GlobalConfig
    LEGACY_PATH = ENV["HOME"] + "/.trello_flow"
    PATH = ENV["HOME"] + "/.cp8_cli"

    def initialize(store = nil)
      @store = store || ConfigStore.new(default_store_path)
    end

    def github_token
      @_github_token ||= store[:github_token] || env_github_token || configure_github_token
    end

    private

      attr_reader :store

      def default_store_path
        migrate_legacy_path

        PATH
      end

      def migrate_legacy_path
        return unless uses_legacy_path?

        Command.say("#{LEGACY_PATH} was deprecated, moving to #{PATH}")
        File.rename(LEGACY_PATH, PATH)
      end

      def uses_legacy_path?
        !File.file?(PATH) && File.file?(LEGACY_PATH)
      end

      def env_github_token
        ENV["OCTOKIT_ACCESS_TOKEN"]
      end

      def configure_github_token
        store.save(
          :github_token,
          Command.ask("Input GitHub access token with repo access scope (https://github.com/settings/tokens):")
        )
      end
  end
end
