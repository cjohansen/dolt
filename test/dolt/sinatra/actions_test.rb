# encoding: utf-8
#--
#   Copyright (C) 2012-2013 Gitorious AS
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

describe Dolt::Sinatra::Actions do
  describe "#blob" do
    it "renders the blob template as html" do
      app = Test::App.new
      dolt = Dolt::Sinatra::Actions.new(app, Test::Lookup.new(Stub::Blob.new), Test::Renderer.new("Blob"))

      dolt.blob("gitorious", "master", "app/models/repository.rb")

      assert_equal "text/html; charset=utf-8", app.response["Content-Type"]
      assert_equal "blob:Blob", app.body
    end
  end

  describe "#tree" do
    it "renders the tree template as html" do
      app = Test::App.new
      dolt = Dolt::Sinatra::Actions.new(app, Test::Lookup.new(Stub::Tree.new), Test::Renderer.new("Tree"))

      dolt.tree("gitorious", "master", "app/models")

      assert_equal "text/html; charset=utf-8", app.response["Content-Type"]
      assert_equal "tree:Tree", app.body
    end
  end

  describe "#tree_entry" do
    it "renders trees with the tree template as html" do
      app = Test::App.new
      dolt = Dolt::Sinatra::Actions.new(app, Test::Lookup.new(Stub::Tree.new), Test::Renderer.new("Tree"))

      dolt.tree_entry("gitorious", "master", "app/models")

      assert_equal "text/html; charset=utf-8", app.response["Content-Type"]
      assert_equal "tree:Tree", app.body
    end
  end

  describe "#raw" do
    it "renders the raw template as text" do
      app = Test::App.new
      dolt = Dolt::Sinatra::Actions.new(app, Test::Lookup.new(Stub::Blob.new), Test::Renderer.new("Text"))

      dolt.raw("gitorious", "master", "app/models/repository.rb")

      assert_equal "text/plain", app.response["Content-Type"]
      assert_equal "raw:Text", app.body
    end
  end

  describe "#blame" do
    it "renders the blame template as html" do
      app = Test::App.new
      dolt = Dolt::Sinatra::Actions.new(app, Test::Lookup.new(Stub::Blob.new), Test::Renderer.new("Text"))

      dolt.blame("gitorious", "master", "app/models/repository.rb")

      assert_equal "text/html; charset=utf-8", app.response["Content-Type"]
      assert_equal "blame:Text", app.body
    end
  end

  describe "#history" do
    it "renders the commits template as html" do
      app = Test::App.new
      dolt = Dolt::Sinatra::Actions.new(app, Test::Lookup.new(Stub::Blob.new), Test::Renderer.new("Text"))

      dolt.history("gitorious", "master", "app/models/repository.rb", 10)

      assert_equal "text/html; charset=utf-8", app.response["Content-Type"]
      assert_equal "commits:Text", app.body
    end
  end

  describe "#refs" do
    it "renders the refs template as json" do
      app = Test::App.new
      dolt = Dolt::Sinatra::Actions.new(app, Test::Lookup.new(Stub::Blob.new), Test::Renderer.new("JSON"))

      dolt.refs("gitorious")

      assert_equal "application/json", app.response["Content-Type"]
      assert_equal "refs:JSON", app.body
    end
  end

  describe "#tree_history" do
    it "renders the tree_history template as json" do
      app = Test::App.new
      dolt = Dolt::Sinatra::Actions.new(app, Test::Lookup.new(Stub::Tree.new), Test::Renderer.new("JSON"))

      dolt.tree_history("gitorious", "master", "", 1)

      assert_equal "application/json", app.response["Content-Type"]
      assert_equal "tree_history:JSON", app.body
    end
  end
end
