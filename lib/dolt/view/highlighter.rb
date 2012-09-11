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
require "pygments"

module Dolt
  module View
    class Highlighter
      def initialize(options = {})
        @options = options
        options[:options] ||= {}
        options[:options][:nowrap] = true
        options[:options][:encoding] = options[:options][:encoding]|| "utf-8"
      end

      def highlight(code, lexer)
        Pygments.highlight(code, options.merge(:lexer => lexer))
      end

      def self.lexer(suffix)
        @@lexer_aliases[suffix] || suffix
      end

      def self.add_lexer_alias(extension, lexer)
        @@lexer_aliases ||= {}
        @@lexer_aliases[extension] = lexer
      end

      private
      def options; @options; end
    end
  end
end

Dolt::View::Highlighter.add_lexer_alias("yml", "yaml")
