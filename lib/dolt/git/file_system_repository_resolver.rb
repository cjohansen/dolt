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
require "dolt/git/shell"
require "dolt/git/repository"

module Dolt
  class FileSystemRepositoryResolver
    def initialize(root)
      @root = root
    end

    def resolve(repo)
      git = Dolt::Git::Shell.new(File.join(root, repo))
      Dolt::Git::Repository.new(repo, git)
    end

    def all
      Dir.entries(root).reject do |e|
        e =~ /^\.+$/ || File.file?(File.join(root, e))
      end
    end

    private
    def root; @root; end
  end
end
