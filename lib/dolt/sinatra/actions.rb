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
  module Sinatra
    module Actions
      # Built-in redirect seems to not work with Sinatra::Async, it throws
      # an error.
      def redirect(url)
        response.status = 302
        response["Location"] = url
        body ""
      end

      def error(error)
        response["Content-Type"] = "text/plain"
        body("Process failed with exit code #{error.exit_code}:\n#{error.message}")
      end

      def blob(repo, path, ref)
        actions.blob(repo, path, ref) do |err, data|
          return error(err) if !err.nil?
          blob = data[:blob]
          return redirect(tree_url(repo, path, ref)) if !blob.is_a?(Rugged::Blob)
          response["Content-Type"] = "text/html"
          body(renderer.render(:blob, data))
        end
      end

      def tree(repo, path, ref)
        actions.tree(repo, path, ref) do |err, data|
          return error(err) if !err.nil?
          tree = data[:tree]
          return redirect(blob_url(repo, path, ref)) if !tree.is_a?(Rugged::Tree)
          response["Content-Type"] = "text/html"
          body(renderer.render(:tree, data))
        end
      end
    end
  end
end
