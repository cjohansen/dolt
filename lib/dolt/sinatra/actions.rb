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
require "dolt/git/error"

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
          if err.nil?
            response["Content-Type"] = "text/html"
            body(renderer.render(:blob, data))
          elsif Dolt::Git::WrongObjectTypeError === err
            redirect(tree_url(repo, path, ref))
          else
            error(err)
          end
        end
      end

      def tree(repo, path, ref)
        actions.tree(repo, path, ref) do |err, data|
          if err.nil?
            response["Content-Type"] = "text/html"
            body(renderer.render(:tree, data))
          elsif Dolt::Git::InvalidObjectNameError === err
            redirect(blob_url(repo, path, ref))
          else
            error(err)
          end
        end
      end
    end
  end
end
