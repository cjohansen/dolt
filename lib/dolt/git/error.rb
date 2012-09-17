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

module Dolt
  module Git
    class AsyncShellError < StandardError
      attr_reader :exit_code

      def initialize(message, exit_code)
        @exit_code = exit_code
        super(message)
      end

      def self.from_process(stderr, status)
        exit_code = status.exitstatus
        if stderr =~ /not a tree object/
          return WrongObjectTypeError.new(stderr, exit_code)
        end
        if stderr =~ /Not a valid object name/
          return InvalidObjectNameError.new(stderr, exit_code)
        end
        NoRepositoryError.new(stderr, exit_code)
      end
    end

    class NoRepositoryError < AsyncShellError; end
    class WrongObjectTypeError < AsyncShellError; end
    class InvalidObjectNameError < AsyncShellError; end
  end
end
