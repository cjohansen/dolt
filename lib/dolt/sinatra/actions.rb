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
require "json"
require "time"
require "cgi"

module Dolt
  module Sinatra
    class Actions
      def initialize(app, lookup, renderer)
        @app = app
        @lookup = lookup
        @renderer = renderer
      end

      def redirect(url, status = 302)
        app.response.status = status
        app.response["Location"] = url
        app.body("")
      end

      def render_error(error, repo, ref, data = {})
        if error.class.to_s == "Rugged::ReferenceError" && ref == "HEAD"
          return app.body(renderer.render("empty", {
                :repository => repo,
                :ref => ref
              }.merge(data)))
        end
        template = error.class.to_s == "Rugged::IndexerError" ? :"404" : :"500"
        add_headers(app.response)
        app.body(renderer.render(template, {
              :error => error,
              :repository_slug => repo,
              :ref => ref
            }.merge(data)))
      rescue Exception => err
        err_backtrace = err.backtrace.map { |s| "<li>#{s}</li>" }
        error_backtrace = error.backtrace.map { |s| "<li>#{s}</li>" }

        app.body(<<-HTML)
        <h1>Fatal Dolt Error</h1>
        <p>
          Dolt encountered an exception, and additionally
          triggered another exception trying to render the error.
        </p>
        <p>Tried to render the #{template} template with the following data:</p>
        <dl>
          <dt>Repository</dt>
          <dd>#{repo}</dd>
          <dt>Ref</dt>
          <dd>#{ref}</dd>
        </dl>
        <h2>Error: #{err.class} #{err.message}</h2>
        <ul>#{err_backtrace.join()}</ul>
        <h2>Original error: #{error.class} #{error.message}</h2>
        <ul>#{error_backtrace.join()}</ul>
        HTML
      end

      def raw(repo, ref, path, custom_data = {})
        if oid = lookup_ref_oid(repo, ref)
          redirect(app.raw_url(repo, oid, path), 307) and return
        end

        blob(repo, ref, path, custom_data, {
            :template => :raw,
            :content_type => "text/plain",
            :template_options => { :layout => nil }
          })
      end

      def blob(repo, ref, path, custom_data = {}, options = { :template => :blob })
        if oid = lookup_ref_oid(repo, ref)
          redirect(app.blob_url(repo, oid, path), 307) and return
        end

        data = (custom_data || {}).merge(lookup.blob(repo, u(ref), path))
        blob = data[:blob]
        return redirect(app.tree_url(repo, ref, path)) if blob.class.to_s !~ /\bBlob/
        add_headers(app.response, options.merge(:ref => ref))
        tpl_options = options[:template_options] || {}
        app.body(renderer.render(options[:template], data, tpl_options))
      end

      def tree(repo, ref, path, custom_data = {})
        if oid = lookup_ref_oid(repo, ref)
          redirect(app.tree_url(repo, oid, path), 307) and return
        end

        data = (custom_data || {}).merge(lookup.tree(repo, u(ref), path))
        tree = data[:tree]
        return redirect(app.blob_url(repo, ref, path)) if tree.class.to_s !~ /\bTree/
        add_headers(app.response, :ref => ref)
        app.body(renderer.render(:tree, data))
      end

      def tree_entry(repo, ref, path, custom_data = {})
        if oid = lookup_ref_oid(repo, ref)
          redirect(app.tree_entry_url(repo, oid, path), 307) and return
        end

        data = (custom_data || {}).merge(lookup.tree_entry(repo, u(ref), path))
        add_headers(app.response, :ref => ref)
        app.body(renderer.render(data.key?(:tree) ? :tree : :blob, data))
      end

      def blame(repo, ref, path, custom_data = {})
        if oid = lookup_ref_oid(repo, ref)
          redirect(app.blame_url(repo, oid, path), 307) and return
        end

        data = (custom_data || {}).merge(lookup.blame(repo, u(ref), path))
        add_headers(app.response, :ref => ref)
        app.body(renderer.render(:blame, data))
      end

      def history(repo, ref, path, count, custom_data = {})
        if oid = lookup_ref_oid(repo, ref)
          redirect(app.history_url(repo, oid, path), 307) and return
        end

        data = (custom_data || {}).merge(lookup.history(repo, u(ref), path, count))
        add_headers(app.response, :ref => ref)
        app.body(renderer.render(:commits, data))
      end

      def refs(repo, custom_data = {})
        data = (custom_data || {}).merge(lookup.refs(repo))
        add_headers(app.response, :content_type => "application/json")
        app.body(renderer.render(:refs, data, :layout => nil))
      end

      def tree_history(repo, ref, path, count = 1, custom_data = {})
        if oid = lookup_ref_oid(repo, ref)
          redirect(app.tree_history_url(repo, oid, path), 307) and return
        end

        data = (custom_data || {}).merge(lookup.tree_history(repo, u(ref), path, count))
        add_headers(app.response, :content_type => "application/json", :ref => ref)
        app.body(renderer.render(:tree_history, data, :layout => nil))
      end

      def resolve_repository(repo)
        @cache ||= {}
        @cache[repo] ||= lookup.resolve_repository(repo)
      end

      def lookup_ref_oid(repo, ref)
        return if !app.respond_to?(:redirect_refs?) || !app.redirect_refs? || ref.length == 40
        lookup.rev_parse_oid(repo, ref)
      end

      private
      attr_reader :app, :lookup, :renderer

      def u(str)
        # Temporarily swap the + out with a magic byte, so
        # filenames/branches with +'s won't get unescaped to a space
        CGI.unescape(str.gsub("+", "\001")).gsub("\001", '+')
      end

      def add_headers(response, headers = {})
        default_ct = "text/html; charset=utf-8"
        response["Content-Type"] = headers[:content_type] || default_ct
        response["X-UA-Compatible"] = "IE=edge"

        if headers[:ref] && headers[:ref].length == 40
          response["Cache-Control"] = "max-age=315360000, public"
          year = 60*60*24*365
          response["Expires"] = (Time.now + year).httpdate
        end
      end
    end
  end
end
