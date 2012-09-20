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
require "em_rugged/repository"
require "em_pessimistic/deferrable_child_process"
require "em/deferrable"
require "dolt/git/blame"

module Dolt
  module Git
    class Repository < EMRugged::Repository
      def blame(ref, path)
        d = EventMachine::DefaultDeferrable.new
        cmd = git("blame -l -t -p #{ref} #{path}")
        p = EMPessimistic::DeferrableChildProcess.open(cmd)

        p.callback do |output, status|
          d.succeed(Dolt::Git::Blame.parse_porcelain(output))
        end

        p.errback do |err|
          d.fail(err)
        end

        d
      end

      private
      def git(cmd)
        "git --git-dir #{subject.path} #{cmd}"
      end
    end
  end
end
