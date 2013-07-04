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
require "dolt/sinatra/base"
require "libdolt/view/multi_repository"
require "libdolt/view/blob"
require "libdolt/view/tree"

module Dolt
  module Sinatra
    class MultiRepoBrowser < Dolt::Sinatra::Base
      include Dolt::View::MultiRepository
      include Dolt::View::Blob
      include Dolt::View::Tree

      not_found { renderer.render("404") }

      get "/" do
        response["Content-Type"] = "text/html"
        body(renderer.render(:index, { :repositories => actions.repositories }))
      end

      get "/:repo" do
        redirect "/#{params[:repo]}/tree/master:"
      end

      get "/*/tree/*:*" do
        begin
          repo, ref, path = params[:splat]
          tree(repo, ref, path)
        rescue Exception => err
          render_error(err, repo, ref)
        end
      end

      get "/*/tree/*" do
        force_ref(params[:splat], "tree", "master")
      end

      get "/*/blob/*:*" do
        begin
          repo, ref, path = params[:splat]
          blob(repo, ref, path)
        rescue Exception => err
          render_error(err, repo, ref)
        end
      end

      get "/*/blob/*" do
        force_ref(params[:splat], "blob", "master")
      end

      get "/*/raw/*:*" do
        begin
          repo, ref, path = params[:splat]
          raw(repo, ref, path)
        rescue Exception => err
          render_error(err, repo, ref)
        end
      end

      get "/*/raw/*" do
        force_ref(params[:splat], "raw", "master")
      end

      get "/*/blame/*:*" do
        begin
          repo, ref, path = params[:splat]
          blame(repo, ref, path)
        rescue Exception => err
          render_error(err, repo, ref)
        end
      end

      get "/*/blame/*" do
        force_ref(params[:splat], "blame", "master")
      end

      get "/*/history/*:*" do
        begin
          repo, ref, path = params[:splat]
          history(repo, ref, path, (params[:commit_count] || 20).to_i)
        rescue Exception => err
          render_error(err, repo, ref)
        end
      end

      get "/*/history/*" do
        force_ref(params[:splat], "history", "master")
      end

      get "/*/refs" do
        begin
          refs(params[:splat].first)
        rescue Exception => err
          render_error(err, repo, nil)
        end
      end

      get "/*/tree_history/*:*" do
        begin
          repo, ref, path = params[:splat]
          tree_history(repo, ref, path)
        rescue Exception => err
          render_error(err, repo, ref)
        end
      end

      private
      def force_ref(args, action, ref)
        redirect(args.shift + "/#{action}/#{ref}:" + args.join)
      end
    end
  end
end
