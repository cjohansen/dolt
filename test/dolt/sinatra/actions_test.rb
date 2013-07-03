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
    it "delegates to actions" do
      actions = Test::Actions.new(Stub::Blob.new)
      app = Test::SinatraApp.new(actions, Test::Renderer.new)
      app.blob("gitorious", "master", "app/models/repository.rb")

      assert_equal "gitorious", actions.repo
      assert_equal "master", actions.ref
      assert_equal "app/models/repository.rb", actions.path
    end

    it "renders the blob template as html" do
      app = Test::SinatraApp.new(Test::Actions.new(Stub::Blob.new), Test::Renderer.new("Blob"))
      app.blob("gitorious", "master", "app/models/repository.rb")

      assert_equal "text/html; charset=utf-8", app.response["Content-Type"]
      assert_equal "blob:Blob", app.body
    end

    it "renders the blob template with custom data" do
      renderer = Test::Renderer.new("Blob")
      app = Test::SinatraApp.new(Test::Actions.new(Stub::Blob.new), renderer)
      app.blob("gitorious", "master", "app/models/repository.rb", { :who => 42 })

      assert_equal 42, renderer.data[:who]
    end

    it "redirects tree views to tree action" do
      app = Test::SinatraApp.new(Test::Actions.new(Stub::Tree.new), Test::Renderer.new("Tree"))
      app.blob("gitorious", "master", "app/models")

      assert_equal 302, app.response.status
      assert_equal "/gitorious/tree/master:app/models", app.response["Location"]
      assert_equal "", app.body
    end

    it "unescapes ref" do
      actions = Test::Actions.new(Stub::Blob.new)
      app = Test::SinatraApp.new(actions, Test::Renderer.new("Blob"))
      app.blob("gitorious", "issue-%23221", "app/my documents")

      assert_equal "issue-#221", actions.ref
    end

    it "does not redirect ref to oid by default" do
      app = Test::SinatraApp.new(Test::Actions.new(Stub::Blob.new), Test::Renderer.new("Blob"))
      app.blob("gitorious", "master", "lib/gitorious.rb")

      location = app.response["Location"]
      refute_equal 302, app.response.status
      refute_equal 307, app.response.status
    end

    it "redirects ref to oid if configured so" do
      app = Test::RedirectingSinatraApp.new(Test::Actions.new(Stub::Blob.new), Test::Renderer.new("Blob"))
      app.blob("gitorious", "master", "lib/gitorious.rb")

      location = app.response["Location"]
      assert_equal 307, app.response.status
      assert_equal "/gitorious/blob/#{'a' * 40}:lib/gitorious.rb", location
      assert_equal "", app.body
    end
  end

  describe "#tree" do
    it "delegates to actions" do
      actions = Test::Actions.new(Stub::Tree.new)
      app = Test::SinatraApp.new(actions, Test::Renderer.new)
      app.tree("gitorious", "master", "app/models")

      assert_equal "gitorious", actions.repo
      assert_equal "master", actions.ref
      assert_equal "app/models", actions.path
    end

    it "renders the tree template as html" do
      app = Test::SinatraApp.new(Test::Actions.new(Stub::Tree.new), Test::Renderer.new("Tree"))
      app.tree("gitorious", "master", "app/models")

      assert_equal "text/html; charset=utf-8", app.response["Content-Type"]
      assert_equal "tree:Tree", app.body
    end

    it "renders template with custom data" do
      renderer = Test::Renderer.new("Tree")
      app = Test::SinatraApp.new(Test::Actions.new(Stub::Tree.new), renderer)
      app.tree("gitorious", "master", "app/models", { :who => 42 })

      assert_equal 42, renderer.data[:who]
    end

    it "redirects blob views to blob action" do
      app = Test::SinatraApp.new(Test::Actions.new(Stub::Blob.new), Test::Renderer.new("Tree"))
      app.tree("gitorious", "master", "app/models/repository.rb")

      location = app.response["Location"]
      assert_equal 302, app.response.status
      assert_equal "/gitorious/blob/master:app/models/repository.rb", location
      assert_equal "", app.body
    end

    it "sets X-UA-Compatible header" do
      app = Test::SinatraApp.new(Test::Actions.new(Stub::Tree.new), Test::Renderer.new("Tree"))
      app.tree("gitorious", "master", "app/models")

      assert_equal "IE=edge", app.response["X-UA-Compatible"]
    end

    it "does not set cache-control header for head ref" do
      app = Test::SinatraApp.new(Test::Actions.new(Stub::Tree.new), Test::Renderer.new("Tree"))
      app.tree("gitorious", "master", "app/models")

      assert !app.response.key?("Cache-Control")
    end

    it "sets cache headers for full oid ref" do
      app = Test::SinatraApp.new(Test::Actions.new(Stub::Tree.new), Test::Renderer.new("Tree"))
      app.tree("gitorious", "a" * 40, "app/models")

      assert_equal "max-age=315360000, public", app.response["Cache-Control"]
      refute_nil app.response["Expires"]
    end

    it "unescapes ref" do
      actions = Test::Actions.new(Stub::Tree.new)
      app = Test::SinatraApp.new(actions, Test::Renderer.new("Tree"))
      app.tree("gitorious", "issue-%23221", "app")

      assert_equal "issue-#221", actions.ref
    end

    it "redirects ref to oid if configured so" do
      app = Test::RedirectingSinatraApp.new(Test::Actions.new(Stub::Tree.new), Test::Renderer.new("Tree"))
      app.tree("gitorious", "master", "lib")

      assert_equal 307, app.response.status
      assert_equal "/gitorious/tree/#{'a' * 40}:lib", app.response["Location"]
    end
  end

  describe "#tree_entry" do
    it "renders trees with the tree template as html" do
      app = Test::SinatraApp.new(Test::Actions.new(Stub::Tree.new), Test::Renderer.new("Tree"))
      app.tree_entry("gitorious", "master", "app/models")

      assert_equal "text/html; charset=utf-8", app.response["Content-Type"]
      assert_equal "tree:Tree", app.body
    end

    it "renders template with custom data" do
      renderer = Test::Renderer.new("Tree")
      app = Test::SinatraApp.new(Test::Actions.new(Stub::Tree.new), renderer)
      app.tree_entry("gitorious", "master", "app/models", { :who => 42 })

      assert_equal 42, renderer.data[:who]
    end

    it "renders trees with the tree template as html" do
      app = Test::SinatraApp.new(Test::Actions.new(Stub::Blob.new), Test::Renderer.new("Blob"))
      app.tree_entry("gitorious", "master", "app/models")

      assert_equal "text/html; charset=utf-8", app.response["Content-Type"]
      assert_equal "blob:Blob", app.body
    end

    it "unescapes ref" do
      actions = Test::Actions.new(Stub::Tree.new)
      app = Test::SinatraApp.new(actions, Test::Renderer.new("Tree"))
      app.tree_entry("gitorious", "issue-%23221", "app")

      assert_equal "issue-#221", actions.ref
    end

    it "redirects ref to oid if configured so" do
      app = Test::RedirectingSinatraApp.new(Test::Actions.new(Stub::Tree.new), Test::Renderer.new("Tree"))
      app.tree_entry("gitorious", "master", "lib")

      assert_equal 307, app.response.status
      assert_equal "/gitorious/source/#{'a' * 40}:lib", app.response["Location"]
    end
  end

  describe "#raw" do
    it "delegates to actions" do
      actions = Test::Actions.new(Stub::Blob.new)
      app = Test::SinatraApp.new(actions, Test::Renderer.new)
      app.raw("gitorious", "master", "app/models/repository.rb")

      assert_equal "gitorious", actions.repo
      assert_equal "master", actions.ref
      assert_equal "app/models/repository.rb", actions.path
    end

    it "renders the raw template as text" do
      app = Test::SinatraApp.new(Test::Actions.new(Stub::Blob.new), Test::Renderer.new("Text"))
      app.raw("gitorious", "master", "app/models/repository.rb")

      assert_equal "text/plain", app.response["Content-Type"]
      assert_equal "raw:Text", app.body
    end

    it "renders template with custom data" do
      renderer = Test::Renderer.new("Text")
      app = Test::SinatraApp.new(Test::Actions.new(Stub::Blob.new), renderer)
      app.raw("gitorious", "master", "app/models/repository.rb", { :who => 42 })

      assert_equal 42, renderer.data[:who]
    end

    it "redirects tree views to tree action" do
      app = Test::SinatraApp.new(Test::Actions.new(Stub::Tree.new), Test::Renderer.new("Tree"))
      app.raw("gitorious", "master", "app/models")

      location = app.response["Location"]
      assert_equal 302, app.response.status
      assert_equal "/gitorious/tree/master:app/models", location
      assert_equal "", app.body
    end

    it "unescapes ref" do
      actions = Test::Actions.new(Stub::Blob.new)
      app = Test::SinatraApp.new(actions, Test::Renderer.new("Blob"))
      app.raw("gitorious", "issue-%23221", "app/models/repository.rb")

      assert_equal "issue-#221", actions.ref
    end

    it "redirects ref to oid if configured so" do
      app = Test::RedirectingSinatraApp.new(Test::Actions.new(Stub::Blob.new), Test::Renderer.new("Blob"))
      app.raw("gitorious", "master", "lib/gitorious.rb")

      assert_equal 307, app.response.status
      assert_equal "/gitorious/raw/#{'a' * 40}:lib/gitorious.rb", app.response["Location"]
    end
  end

  describe "#blame" do
    it "delegates to actions" do
      actions = Test::Actions.new(Stub::Blob.new)
      app = Test::SinatraApp.new(actions, Test::Renderer.new)
      app.blame("gitorious", "master", "app/models/repository.rb")

      assert_equal "gitorious", actions.repo
      assert_equal "master", actions.ref
      assert_equal "app/models/repository.rb", actions.path
    end

    it "renders the blame template as html" do
      app = Test::SinatraApp.new(Test::Actions.new(Stub::Blob.new), Test::Renderer.new("Text"))
      app.blame("gitorious", "master", "app/models/repository.rb")

      assert_equal "text/html; charset=utf-8", app.response["Content-Type"]
      assert_equal "blame:Text", app.body
    end

    it "renders template with custom data" do
      renderer = Test::Renderer.new("Text")
      app = Test::SinatraApp.new(Test::Actions.new(Stub::Blob.new), renderer)
      app.blame("gitorious", "master", "app/models/repository.rb", { :who => 42 })

      assert_equal 42, renderer.data[:who]
    end

    it "unescapes ref" do
      actions = Test::Actions.new(Stub::Blob.new)
      app = Test::SinatraApp.new(actions, Test::Renderer.new("Blob"))
      app.blame("gitorious", "issue-%23221", "app/models/repository.rb")

      assert_equal "issue-#221", actions.ref
    end

    it "redirects ref to oid if configured so" do
      app = Test::RedirectingSinatraApp.new(Test::Actions.new(Stub::Blob.new), Test::Renderer.new("Blob"))
      app.blame("gitorious", "master", "lib/gitorious.rb")

      assert_equal 307, app.response.status
      assert_equal "/gitorious/blame/#{'a' * 40}:lib/gitorious.rb", app.response["Location"]
    end
  end

  describe "#history" do
    it "delegates to actions" do
      actions = Test::Actions.new(Stub::Blob.new)
      app = Test::SinatraApp.new(actions, Test::Renderer.new)
      app.history("gitorious", "master", "app/models/repository.rb", 10)

      assert_equal "gitorious", actions.repo
      assert_equal "master", actions.ref
      assert_equal "app/models/repository.rb", actions.path
    end

    it "renders the commits template as html" do
      app = Test::SinatraApp.new(Test::Actions.new(Stub::Blob.new), Test::Renderer.new("Text"))
      app.history("gitorious", "master", "app/models/repository.rb", 10)

      assert_equal "text/html; charset=utf-8", app.response["Content-Type"]
      assert_equal "commits:Text", app.body
    end

    it "renders template with custom data" do
      renderer = Test::Renderer.new("Text")
      app = Test::SinatraApp.new(Test::Actions.new(Stub::Blob.new), renderer)
      app.history("gitorious", "master", "app/models/repository.rb", 10, { :who => 42 })

      assert_equal 42, renderer.data[:who]
    end

    it "unescapes ref" do
      actions = Test::Actions.new(Stub::Blob.new)
      app = Test::SinatraApp.new(actions, Test::Renderer.new("Blob"))
      app.history("gitorious", "issue-%23221", "lib/gitorious.rb", 10)

      assert_equal "issue-#221", actions.ref
    end

    it "redirects ref to oid if configured so" do
      app = Test::RedirectingSinatraApp.new(Test::Actions.new(Stub::Blob.new), Test::Renderer.new("Blob"))
      app.history("gitorious", "master", "lib/gitorious.rb", 10)

      assert_equal 307, app.response.status
      assert_equal "/gitorious/history/#{'a' * 40}:lib/gitorious.rb", app.response["Location"]
    end
  end

  describe "#refs" do
    it "renders the refs template as json" do
      app = Test::SinatraApp.new(Test::Actions.new(Stub::Blob.new), Test::Renderer.new("JSON"))
      app.refs("gitorious")

      assert_equal "application/json", app.response["Content-Type"]
      assert_equal "refs:JSON", app.body
    end

    it "renders template with custom data" do
      renderer = Test::Renderer.new("Text")
      app = Test::SinatraApp.new(Test::Actions.new(Stub::Blob.new), renderer)
      app.refs("gitorious", { :who => 42 })

      assert_equal 42, renderer.data[:who]
    end
  end

  describe "#tree_history" do
    it "renders the tree_history template as json" do
      app = Test::SinatraApp.new(Test::Actions.new(Stub::Tree.new), Test::Renderer.new("JSON"))
      app.tree_history("gitorious", "master", "", 1)

      assert_equal "application/json", app.response["Content-Type"]
      assert_equal "tree_history:JSON", app.body
    end

    it "renders template with custom data" do
      renderer = Test::Renderer.new("Text")
      app = Test::SinatraApp.new(Test::Actions.new(Stub::Tree.new), renderer)
      app.tree_history("gitorious", "master", "app/models", 1, { :who => 42 })

      assert_equal 42, renderer.data[:who]
    end

    it "unescapes ref" do
      actions = Test::Actions.new(Stub::Tree.new)
      app = Test::SinatraApp.new(actions, Test::Renderer.new("Tree"))
      app.tree_history("gitorious", "issue-%23221", "app/models")

      assert_equal "issue-#221", actions.ref
    end

    it "redirects ref to oid if configured so" do
      app = Test::RedirectingSinatraApp.new(Test::Actions.new(Stub::Tree.new), Test::Renderer.new("Tree"))
      app.tree_history("gitorious", "master", "lib", 10)

      assert_equal 307, app.response.status
      assert_equal "/gitorious/tree_history/#{'a' * 40}:lib", app.response["Location"]
    end
  end
end
