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
require "bundler/setup"
require "minitest/autorun"
require "em/minitest/spec"
require "eventmachine"

Bundler.require(:default, :test)

module Moron
  module StdioStub
    def silence_stderr
      new_stderr = $stderr.dup
      rd, wr = IO::pipe
      $stderr.reopen(wr)
      yield
      $stderr.reopen(new_stderr)
    end

    def silence_stdout
      new_stdout = $stdout.dup
      rd, wr = IO::pipe
      $stdout.reopen(wr)
      yield
      $stdout.reopen(new_stdout)
    end
  end
end
