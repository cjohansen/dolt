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
    class Tree
      attr_reader :path, :entries

      def initialize(path, entries)
        @path = path
        @entries = entries
      end

      def self.parse(path, ls_tree_payload)
        paths = ls_tree_payload.split("\n").collect do |line|
          pieces = line.split(/\s+/)
          klass = pieces[1] == "blob" ? File : Dir
          klass.new(pieces[3], pieces[2], pieces[0])
        end

        new(path, paths)
      end

      class Entry
        attr_reader :path, :sha, :mode

        def initialize(path, sha, mode)
          @path = path
          @sha = sha
          @mode = mode
        end

        def file?; false; end
        def dir?; false; end
      end

      class File < Entry
        def file?; true; end
      end

      class Dir < Entry
        def dir?; true; end
      end
    end
  end
end
