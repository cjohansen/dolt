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
require "dolt/view/base"
require "dolt/view/highlighter"

module Dolt
  module View
    module Blob
      def blame_url(repository, ref, path)
        repo_url(repository, "/blame/#{ref}:#{path}")
      end

      def history_url(repository, ref, path)
        repo_url(repository, "/history/#{ref}:#{path}")
      end

      def raw_url(repository, ref, path)
        repo_url(repository, "/raw/#{ref}:#{path}")
      end

      def multiline(blob, options = {})
        class_names = options[:class_names] || []
        class_names << "prettyprint" << "linenums"

        num = 0
        lines = blob.split("\n").inject("") do |html, line|
          num += 1
          "#{html}<li class=\"L#{num}\"><span class=\"line\">#{line}</span></li>"
        end

        "<pre class=\"#{class_names.join(' ')}\">" +
          "<ol class=\"linenums\">#{lines}</ol></pre>"
      end

      def highlight(path, code, options = {})
        lexer = lexer_for_file(path)
        Dolt::View::Highlighter.new(options).highlight(code, lexer)
      rescue RubyPython::PythonError
        code
      end

      def highlight_lines(path, code, options = {})
        lexer = lexer_for_file(path)
        multiline(highlight(path, code, options), :class_names => [lexer])
      end

      def lexer_for_file(path)
        suffix = path.split(".").pop
        Dolt::View::Highlighter.lexer(suffix)
      end
    end
  end
end
