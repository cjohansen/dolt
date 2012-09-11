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
require "eventmachine"

module Dolt
  class RepoActions
    def initialize(repo_resolver)
      @repo_resolver = repo_resolver
    end

    def blob(repo, ref, path, &block)
      repository = repo_resolver.resolve(repo)
      d = repository.blob(path, ref)
      d.callback do |blob, status|
        block.call(nil, {
                     :blob => blob,
                     :repository => repository,
                     :ref => ref })
      end
      d.errback { |err| block.call(err, nil) }
    end

    def tree(repo, path, ref, &block)
      repository = repo_resolver.resolve(repo)
      d = repository.tree(path, ref)
      d.callback do |tree, status|
        block.call(nil, {
                     :tree => tree,
                     :repository => repository,
                     :ref => ref })
      end
      d.errback { |err| block.call(err, nil) }
    end

    private
    def repo_resolver; @repo_resolver; end
  end
end
