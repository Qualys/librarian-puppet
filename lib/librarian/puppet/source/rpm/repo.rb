require 'librarian/puppet/version'
require 'librarian/puppet/source/repo'

module Librarian
  module Puppet
    module Source
      class RPM
        class Repo < Librarian::Puppet::Source::Repo
          include Librarian::Puppet::Util

          def versions
            # We only ever have a single possible match for a version
            Librarian::Posix.run!(%W{yum -q list avaliable #{source.to_s}})
          end



        end
      end
    end
  end
end
