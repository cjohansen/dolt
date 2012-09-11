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
  # A deferrable child process implementation that actually considers
  # the not uncommon situation where the command fails.
  #
  class DeferrableChildProcess < EventMachine::Connection
    include EventMachine::Deferrable

    def initialize
      super
      @data = []
    end

    def self.open cmd
      EventMachine.popen(cmd, DeferrableChildProcess)
    end

    def receive_data data
      @data << data
    end

    def unbind
      status = get_status
      if status.exitstatus != 0
        fail(status)
      else
        succeed(@data.join, status)
      end
    end
  end
end
