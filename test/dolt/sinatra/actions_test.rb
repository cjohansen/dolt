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
require "test_helper"
require "dolt/sinatra/actions"

class DummySinatraApp
  include Dolt::Sinatra::Actions
  attr_reader :actions, :renderer

  def initialize(actions, renderer)
    @actions = actions
    @renderer = renderer
  end

  def body(str = nil)
    @body = str if !str.nil?
    @body
  end

  def response
    if !@response
      @response = {}
      def @response.status; @status; end
      def @response.status=(status); @status = status; end
    end
    @response
  end

  def tree_url(repo, ref, path)
    "/#{repo}/tree/#{ref}:#{path}"
  end

  def blob_url(repo, ref, path)
    "/#{repo}/blob/#{ref}:#{path}"
  end
end

class Renderer
  def initialize(body = ""); @body = body; end

  def render(action, data, options = {})
    @action = action
    @data = data
    "#{action}:#@body"
  end
end

class BlobStub
  def is_a?(type)
    type == Rugged::Blob
  end
end

class TreeStub
  def is_a?(type)
    type == Rugged::Tree
  end
end

class Actions
  attr_reader :repo, :ref, :path

  def initialize(response)
    @response = response
  end

  def blob(repo, ref, path, &block)
    respond(:blob, repo, ref, path, &block)
  end

  def tree(repo, ref, path, &block)
    respond(:tree, repo, ref, path, &block)
  end

  def raw(repo, ref, path, &block)
    respond(:raw, repo, ref, path, &block)
  end

  def blame(repo, ref, path, &block)
    respond(:blame, repo, ref, path, &block)
  end

  def respond(type, repo, ref, path, &block)
    @repo = repo
    @ref = ref
    @path = path
    data = { :ref => ref, :repository => repo }
    data[type] = @response
    block.call(nil, data)
  end
end

describe Dolt::Sinatra::Actions do
  describe "#blob" do
    it "delegates to actions" do
      actions = Actions.new(BlobStub.new)
      app = DummySinatraApp.new(actions, Renderer.new)
      app.blob("gitorious", "master", "app/models/repository.rb")

      assert_equal "gitorious", actions.repo
      assert_equal "master", actions.ref
      assert_equal "app/models/repository.rb", actions.path
    end

    it "renders the blob template as html" do
      app = DummySinatraApp.new(Actions.new(BlobStub.new), Renderer.new("Blob"))
      app.blob("gitorious", "master", "app/models/repository.rb")

      assert_equal "text/html", app.response["Content-Type"]
      assert_equal "blob:Blob", app.body
    end

    it "redirects tree views to tree action" do
      app = DummySinatraApp.new(Actions.new(TreeStub.new), Renderer.new("Blob"))
      app.blob("gitorious", "master", "app/models")

      assert_equal 302, app.response.status
      assert_equal "/gitorious/tree/master:app/models", app.response["Location"]
      assert_equal "", app.body
    end
  end

  describe "#tree" do
    it "delegates to actions" do
      actions = Actions.new(TreeStub.new)
      app = DummySinatraApp.new(actions, Renderer.new)
      app.tree("gitorious", "master", "app/models")

      assert_equal "gitorious", actions.repo
      assert_equal "master", actions.ref
      assert_equal "app/models", actions.path
    end

    it "renders the tree template as html" do
      app = DummySinatraApp.new(Actions.new(TreeStub.new), Renderer.new("Tree"))
      app.tree("gitorious", "master", "app/models")

      assert_equal "text/html", app.response["Content-Type"]
      assert_equal "tree:Tree", app.body
    end

    it "redirects blob views to blob action" do
      app = DummySinatraApp.new(Actions.new(BlobStub.new), Renderer.new("Tree"))
      app.tree("gitorious", "master", "app/models/repository.rb")

      location = app.response["Location"]
      assert_equal 302, app.response.status
      assert_equal "/gitorious/blob/master:app/models/repository.rb", location
      assert_equal "", app.body
    end
  end

  describe "#raw" do
    it "delegates to actions" do
      actions = Actions.new(BlobStub.new)
      app = DummySinatraApp.new(actions, Renderer.new)
      app.raw("gitorious", "master", "app/models/repository.rb")

      assert_equal "gitorious", actions.repo
      assert_equal "master", actions.ref
      assert_equal "app/models/repository.rb", actions.path
    end

    it "renders the raw template as text" do
      app = DummySinatraApp.new(Actions.new(BlobStub.new), Renderer.new("Text"))
      app.raw("gitorious", "master", "app/models/repository.rb")

      assert_equal "text/plain", app.response["Content-Type"]
      assert_equal "raw:Text", app.body
    end

    it "redirects tree views to tree action" do
      app = DummySinatraApp.new(Actions.new(TreeStub.new), Renderer.new("Tree"))
      app.raw("gitorious", "master", "app/models")

      location = app.response["Location"]
      assert_equal 302, app.response.status
      assert_equal "/gitorious/tree/master:app/models", location
      assert_equal "", app.body
    end
  end

  describe "#blame" do
    it "delegates to actions" do
      actions = Actions.new(BlobStub.new)
      app = DummySinatraApp.new(actions, Renderer.new)
      app.blame("gitorious", "master", "app/models/repository.rb")

      assert_equal "gitorious", actions.repo
      assert_equal "master", actions.ref
      assert_equal "app/models/repository.rb", actions.path
    end

    it "renders the blame template as text" do
      app = DummySinatraApp.new(Actions.new(BlobStub.new), Renderer.new("Text"))
      app.blame("gitorious", "master", "app/models/repository.rb")

      assert_equal "text/html", app.response["Content-Type"]
      assert_equal "blame:Text", app.body
    end
  end
end
