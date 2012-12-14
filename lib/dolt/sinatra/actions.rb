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
require "json"

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

      def error(error, repo, ref)
        response["Content-Type"] = "text/html"
        body(renderer.render(:"500", {
                               :error => error,
                               :repository_slug => repo,
                               :ref => ref
                             }))
      rescue Exception => err
        err_backtrace = err.backtrace.map { |s| "<li>#{s}</li>" }
        error_backtrace = error.backtrace.map { |s| "<li>#{s}</li>" }

        body(<<-HTML)
        <h1>Fatal Dolt Error</h1>
        <p>
          Dolt encountered an exception, and additionally
          triggered another exception trying to render the error.
        </p>
        <h2>Error: #{err.class} #{err.message}</h2>
        <ul>#{err_backtrace.join()}</ul>
        <h2>Original error: #{error.class} #{error.message}</h2>
        <ul>#{error_backtrace.join()}</ul>
        HTML
      end

      def raw(repo, ref, path)
        blob(repo, ref, path, {
               :template => :raw,
               :content_type => "text/plain",
               :template_options => { :layout => nil }
             })
      end

      def blob(repo, ref, path, options = { :template => :blob, :content_type => "text/html" })
        actions.blob(repo, ref, path) do |err, data|
          next error(err, repo, ref) if !err.nil?
          blob = data[:blob]
          next redirect(tree_url(repo, ref, path)) if blob.class.to_s !~ /\bBlob/
          response["Content-Type"] = options[:content_type]
          tpl_options = options[:template_options] || {}
          body(renderer.render(options[:template], data, tpl_options))
        end
      end

      def tree(repo, ref, path)
        actions.tree(repo, ref, path) do |err, data|
          begin
            next error(err, repo, ref) if !err.nil?
            tree = data[:tree]
            next redirect(blob_url(repo, ref, path)) if tree.class.to_s !~ /\bTree/
            response["Content-Type"] = "text/html"
            body(renderer.render(:tree, data))
          rescue Exception => err
            error(err, repo, ref)
          end
        end
      end

      def tree_entry(repo, ref, path)
        actions.tree_entry(repo, ref, path) do |err, data|
          begin
            next error(err, repo, ref) if !err.nil?
            response["Content-Type"] = "text/html"
            body(renderer.render(data.key?(:tree) ? :tree : :blob, data))
          rescue Exception => err
            error(err, repo, ref)
          end
        end
      end

      def blame(repo, ref, path)
        actions.blame(repo, ref, path) do |err, data|
          next error(err, repo, ref) if !err.nil?
          response["Content-Type"] = "text/html"
          body(renderer.render(:blame, data))
        end
      end

      def history(repo, ref, path, count)
        actions.history(repo, ref, path, count) do |err, data|
          next error(err, repo, ref) if !err.nil?
          response["Content-Type"] = "text/html"
          body(renderer.render(:commits, data))
        end
      end

      def refs(repo)
        actions.refs(repo) do |err, data|
          next error(err, repo, ref) if !err.nil?
          response["Content-Type"] = "application/json"
          body(renderer.render(:refs, data, :layout => nil))
        end
      end

      def tree_history(repo, ref, path, count = 1)
        actions.tree_history(repo, ref, path, count) do |err, data|
          if !err.nil?
            error(err, repo, ref)
          else
            response["Content-Type"] = "application/json"
            body(renderer.render(:tree_history, data, :layout => nil))
          end
        end
      end
    end
  end
end
