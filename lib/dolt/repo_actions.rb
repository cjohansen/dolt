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
      d = repository.rev_parse("#{ref}:#{path}")
      d.callback do |blob|
        block.call(nil, tpl_data(repo, ref, path, { :blob => blob }))
      end
      d.errback { |err| block.call(err, nil) }
    end

    def tree(repo, ref, path, &block)
      repository = repo_resolver.resolve(repo)
      d = repository.rev_parse("#{ref}:#{path}")
      d.callback do |tree|
        block.call(nil, tpl_data(repo, ref, path, { :tree => tree }))
      end
      d.errback { |err| block.call(err, nil) }
    end

    def blame(repo, ref, path, &block)
      repository = repo_resolver.resolve(repo)
      d = repository.blame(ref, path)
      d.callback do |blame|
        block.call(nil, tpl_data(repo, ref, path, { :blame => blame }))
      end
      d.errback { |err| block.call(err, nil) }
    end

    private
    def repo_resolver; @repo_resolver; end

    def tpl_data(repo, ref, path, locals = {})
      {
        :repository => repo,
        :path => path,
        :ref => ref
      }.merge(locals)
    end
  end
end
