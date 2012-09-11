# encoding: utf-8
#--
#   Copyright (C) 2012 Gitorious AS
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#++
require "dolt/async/when"
require "dolt/git/blob"
require "dolt/git/tree"

module Dolt
  module Git
    class Repository
      attr_reader :name

      def initialize(name, git = nil)
        @name = name
        @git = git
      end

      def blob(path, ref = "HEAD")
        async_git(git.show(path, ref)) do |data, status|
          Dolt::Git::Blob.new(path, data)
        end
      end

      def tree(path, ref = "HEAD")
        async_git(git.ls_tree(path, ref)) do |data, status|
          Dolt::Git::Tree.parse(path, data)
        end
      end

      private
      def git; @git; end

      def async_git(gitop, &block)
        deferred = When::Deferred.new

        gitop.callback do |data, status|
          deferred.resolve(block.call(data, status))
        end

        gitop.errback { |err| deferred.reject(err) }
        deferred.promise
      end
    end
  end
end
