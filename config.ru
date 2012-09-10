how_to_run = "env REPO_ROOT=/some/git/repos rackup -Ilib"

begin
  require "moron/server/sinatra_server"
  require "moron/server"
  require "moron/file_system_repository_resolver"
  require "moron/template_renderer"
  require "moron/view"
rescue LoadError => err
  puts("Failed loading some dependencies:\n#{err.message}\n\n")
  puts("Make sure you Rackup with the right load path:")
  puts("    #{how_to_run}")
  exit(1)
end

if ENV["REPO_ROOT"].nil?
  puts("Please provide the REPO_ROOT environment variable")
  puts("It should point to the directory where you keep your Git repos")
  puts("    #{how_to_run}")
  exit(1)
end

# Repository lookups
root = ENV["REPO_ROOT"]
model = Moron::Server.new(Moron::FileSystemRepositoryResolver.new(root))

# View configuration
template_root = File.join(File.dirname(__FILE__), "views")
options = { :cache => false, :layout => "layout" }
view = Moron::TemplateRenderer.new(template_root, options)
view.helper(Moron::View)

# Initialize and start the app server
Moron::SinatraServer.set(:public_folder, "vendor/ui")
run Moron::SinatraServer.new(model, view)

puts "Moron currently only supports browsing blobs, try at /<repo>/blob/<ref>:<path>\n\n"
