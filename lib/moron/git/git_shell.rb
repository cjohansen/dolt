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
require "moron/async/deferrable_child_process"

module Moron
  class GitShell
    def initialize(work_tree, git_dir = nil)
      @work_tree = work_tree
      @git_dir = git_dir || File.join(work_tree, ".git")
    end

    def git(command, *args)
      base = "git --git-dir #{@git_dir} --work-tree #{@work_tree}"
      cmd = "#{base} #{command} #{args.join(' ')}".strip
      Moron::DeferrableChildProcess.open(cmd)
    end
  end
end