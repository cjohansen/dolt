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

      get "/" do
        response["Content-Type"] = "text/html"
        body(renderer.render(:index, { :repositories => actions.repositories }))
      end

      get "/*/tree/*:*" do
        repo, ref, path = params[:splat]
        tree(repo, ref, path)
      end

      get "/*/tree/*" do
        force_ref(params[:splat], "tree", "master")
      end

      get "/*/blob/*:*" do
        repo, ref, path = params[:splat]
        blob(repo, ref, path)
      end

      get "/*/blob/*" do
        force_ref(params[:splat], "blob", "master")
      end

      get "/*/raw/*:*" do
        repo, ref, path = params[:splat]
        raw(repo, ref, path)
      end

      get "/*/raw/*" do
        force_ref(params[:splat], "raw", "master")
      end

      get "/*/blame/*:*" do
        repo, ref, path = params[:splat]
        blame(repo, ref, path)
      end

      get "/*/blame/*" do
        force_ref(params[:splat], "blame", "master")
      end

      get "/*/history/*:*" do
        repo, ref, path = params[:splat]
        history(repo, ref, path, (params[:commit_count] || 20).to_i)
      end

      get "/*/history/*" do
        force_ref(params[:splat], "history", "master")
      end

      get "/*/refs" do
        refs(params[:splat].first)
      end

      get "/*/tree_history/*:*" do
        repo, ref, path = params[:splat]
        tree_history(repo, ref, path)
      end

      private
      def force_ref(args, action, ref)
        redirect(args.shift + "/#{action}/#{ref}:" + args.join)
      end
    end
  end
end
