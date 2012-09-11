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
module Addlepate
  module View
    class Breadcrumb
      def render(repository, ref, path)
        dirs = path.split("/")
        filename = dirs.pop
        dir_html = accumulate_dirs(dirs, repository.name, ref)
        <<-HTML
          <ul class="breadcrumb">
            <li><a href="/files"><i class="icon icon-file"></i></a></li>
            #{dir_html}<li class="active">#{filename}</li>
          </ul>
        HTML
      end

      private
      def accumulate_dirs(dirs, repo, ref)
        accumulated = []
        dir_html = dirs.inject("") do |html, dir|
          accumulated << dir
          "#{html}<li><a href=\"/#{repo}/tree/#{ref}:#{accumulated.join('/')}\">" +
            "#{dir}<span class=\"divider\">/</span></a></li>"
        end

      end
    end
  end
end
