require "dir_cache"

class Builder
  class FrontendJS
    class Install
      def initialize(script:, path:)
        self.script = script
        self.path = path
        setup_caches
        caches.each(&:prime)
      end

      def script
        versions + (@script || npm + jspm + bower)
      end

      def save_caches
        caches.each(&:save)
      end

      protected

      attr_accessor :path, :caches
      attr_writer :script

      private

      def setup_caches
        self.caches = []
        caches << cache_for("package.json", "node_modules") if npm?
        caches << cache_for("bower.json", "bower_components") if bower?
        caches << cache_for("config.js", "jspm_packages") if jspm?
      end

      def cache_for(config, dirname)
        DirCache.new(path: path, config: config, dirname: dirname)
      end


      def jspm
        commands = []
        return commands unless jspm?
        commands << "jspm config registries.github.auth #{ENV["JSPM_GITHUB_TOKEN"]}" if ENV["JSPM_GITHUB_TOKEN"]
        commands << "jspm install"
        commands
      end

      def jspm?
        return unless exist?("package.json")
        package = JSON.load(File.read(File.join(path, "package.json")))
        return unless package
        !package["jspm"].nil?
      end

      def npm
        return [] unless npm?
        ["npm install"]
      end

      def npm?
        exist? "package.json"
      end

      def bower
        return [] unless bower?
        ["bower update --allow-root"]
      end

      def bower?
        exist? "bower.json"
      end

      def versions
        vers = ["node --version"]
        vers += ["npm --version"] if npm?
        vers += ["jspm --version"] if jspm?
        vers += ["bower --version"] if bower?
        vers
      end

      def exist?(file)
        File.exist?(File.join(path, file))
      end
    end
  end
end
