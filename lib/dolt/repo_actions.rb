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
      repo_action(repo, ref, path, :blob, :rev_parse, "#{ref}:#{path}", &block)
    end

    def tree(repo, ref, path, &block)
      repo_action(repo, ref, path, :tree, :rev_parse, "#{ref}:#{path}", &block)
    end

    def blame(repo, ref, path, &block)
      repo_action(repo, ref, path, :blame, :blame, ref, path, &block)
    end

    private
    def repo_resolver; @repo_resolver; end

    def repo_action(repo, ref, path, data, method, *args, &block)
      repository = repo_resolver.resolve(repo)
      d = repository.send(method, *args)
      d.callback do |result|
        block.call(nil, tpl_data(repo, ref, path, { data => result }))
      end
      d.errback { |err| block.call(err, nil) }
    end

    def tpl_data(repo, ref, path, locals = {})
      {
        :repository => repo,
        :path => path,
        :ref => ref
      }.merge(locals)
    end
  end
end
