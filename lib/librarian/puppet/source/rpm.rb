require 'librarian/puppet/util'
require 'librarian/puppet/source/rpm/repo'
require 'librarian/source/basic_api'

module Librarian
  module Puppet
    module Source
      class RPM
        include Librarian::Puppet::Util
        include BasicApi

        lock_name 'RPM'
        spec_options [:version, :release]

        attr_accessor :environment
        private :environment=
        attr_reader :package_name, :version, :release

        def initialize(environment, package_name, options = {})
          self.environment = environment
          @package_name = package_name
          @version = options[:version]
          @release = options[:release]
          @cache_path = nil
        end

        def to_s
          ret = "#{package_name}"
          ret = ret + "-#{version}" if version
          ret = ret + "-#{release}" if version && release
          ret
        end

        def ==(other)
          other &&
          self.class == other.class &&
          self.package_name == other.package_name &&
          self.version == other.version &&
          self.release == other.release
        end

        alias :eql? :==

        def hash
          self.to_s.hash
        end

        def to_spec_args
          options = {}
          options.merge!(:version => version) if version
          options.merge!(:release => release) if version && release
          [package_name, options]
        end

        def to_lock_options
          options = {:remote => package_name}
          options.merge!(:version => version) if version
          options.merge!(:release => release) if version && release
          options
        end

        def pinned?
          false
        end

        def unpin!
        end

        def install!(manifest)
          manifest.source == self or raise ArgumentError

          debug { "Installing #{manifest}" }

          name = manifest.name
          version = manifest.version
          install_path = install_path(name)
          repo = repo(name)

          repo.install_version! version, install_path
        end

        def manifest(name, version, dependencies)
          manifest = Manifest.new(self, name)
          manifest.version = version
          manifest.dependencies = dependencies
          manifest
        end

        def cache_path
          @cache_path ||= begin
            environment.cache_path.join("source/puppet/githubtarball/#{package_name}")
          end
        end

        def install_path(name)
          environment.install_path.join(module_name(name))
        end

        def fetch_version(name, version_uri)
          versions = repo(name).versions
          if versions.include? version_uri
            version_uri
          else
            versions.first
          end
        end

        def fetch_dependencies(name, version, version_uri)
          {}
        end

        def manifests(name)
          repo(name).manifests
        end

      private

        def repo(name)
          @repo ||= {}
          @repo[name] ||= Repo.new(self, name)
        end
      end
    end
  end
end
