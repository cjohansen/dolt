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
        options = { :lexer => lexer(path, code) }.merge(opt)
        Pygments.highlight(code, highlight_options(options))
      rescue RubyPython::PythonError
        code
      end

      def highlight_multiline(path, code, options = {})
        return highlight(path, code, options) unless respond_to?(:multiline)
        lexer = lexer(path, code)
        multiline(highlight(path, code, options), :class_names => [lexer])
      end

      def format_blob(path, code, options = {})
        highlight_multiline(path, code, options)
      end

      def lexer(path, code = nil)
        Dolt::View::SyntaxHighlight.lexer(path.split(".").pop, code)
      end

      def self.lexer(suffix, code = nil)
        return @@lexer_aliases[suffix] if @@lexer_aliases[suffix]
        shebang_language(shebang(code)) || suffix
      end

      def self.shebang(code)
        first_line = (code || "").split("\n")[0]
        first_line =~ /^#!/ ? first_line : nil
      end

      def self.shebang_language(shebang)
        shebang = @@lexer_shebangs.find { |s| (shebang || "") =~ s[:pattern] }
        shebang && shebang[:lexer]
      end

      def self.add_lexer_alias(extension, lexer)
        @@lexer_aliases ||= {}
        @@lexer_aliases[extension] = lexer
      end

      def self.add_lexer_shebang(pattern, lexer)
        @@lexer_shebangs ||= []
        @@lexer_shebangs << { :pattern => pattern, :lexer => lexer }
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

Dolt::View::SyntaxHighlight.add_lexer_shebang(/\bruby\b/, "rb")
