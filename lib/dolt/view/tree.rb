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
  module View
    module Tree
      def tree_url(repository, ref, path)
        repo_url(repository, "/tree/#{ref}:#{path}")
      end

      def tree_entries(tree)
        sort(tree.entries.select { |e| e[:type] == :tree }) +
          sort(tree.entries.select { |e| e[:type] == :blob })
      end

      def tree_context(repo, ref, path)
        acc = ""
        pieces = path.sub(/^\.?\//, "").split("/")
        total = 5 + pieces.length
        colspan = total
        pieces.inject("") do |html, dir|
          padding_td = tree_table_padding_td(acc.sub(/^\.?\//, ""))
          url = object_url(repo, ref, acc, { :type => :tree, :name => dir })
          acc << "/#{dir}"
          colspan -= 1
          <<-HTML
            #{html}
            <tr>
              #{padding_td}
              <td colspan="#{colspan}">
                <a href=\"#{url}\">
                  <i class="icon icon-folder-open"></i> #{dir}
                </a>
              </td>
            </tr>
          HTML
        end
      end

      def tree_table_padding_td(path)
        "<td></td>" * tree_table_padding_width(path)
      end

      def tree_table_padding_width(path)
        path.split("/").length
      end

      private
      def sort(entries)
        entries.sort_by { |e| e[:name] }
      end
    end
  end
end
