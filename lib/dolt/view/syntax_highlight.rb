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
    module SyntaxHighlight
      def highlight(path, code, opt = {})
        options = { :lexer => lexer_for_file(path) }.merge(opt)
        Pygments.highlight(code, highlight_options(options))
      rescue RubyPython::PythonError
        code
      end

      def format_blob(path, code, options = {})
        lexer = lexer_for_file(path)
        multiline(highlight(path, code, options), :class_names => [lexer])
      end

      def lexer_for_file(path)
        suffix = path.split(".").pop
        Dolt::View::SyntaxHighlight.lexer(suffix)
      end

      def self.lexer(suffix)
        @@lexer_aliases[suffix] || suffix
      end

      def self.add_lexer_alias(extension, lexer)
        @@lexer_aliases ||= {}
        @@lexer_aliases[extension] = lexer
      end

      private
      def highlight_options(options = {})
        options[:options] ||= {}
        options[:options][:nowrap] = true
        options[:options][:encoding] ||= "utf-8"
        options
      end
    end
  end
end

Dolt::View::SyntaxHighlight.add_lexer_alias("yml", "yaml")
Dolt::View::SyntaxHighlight.add_lexer_alias("Rakefile", "rb")
Dolt::View::SyntaxHighlight.add_lexer_alias("Gemfile", "rb")
Dolt::View::SyntaxHighlight.add_lexer_alias("gemspec", "rb")
