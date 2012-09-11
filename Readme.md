# Dolt - The Git project browser

Dolt is a stand-alone server that allows you to browse git repositories in your
browser. It uses Pygments to syntax highlight code, and displays blame as well
as git history for individual files.

Dolt can also be used as a library to serve git trees from e.g. a Rails app. It
is the blob viewer implementation that will be used in the Gitorious application
(gitorious.org) when it is ready.

## Blobs

Dolt currenly only serves blobs. The sample Rack application that comes with
Dolt allows you to surf repos locally on your disk:

    env REPO_ROOT=/where/git/repos/reside rackup -Ilib

That command will start the server, and allow you to view blobs in repos
available in the `/where/git/repos/reside` directory. For example, on my machine,
when I issue:

    env REPO_ROOT=/home/christian/projects rackup -Ilib

I can go to [http://localhost:9292/gitorious/blob/master:app/models/repository.rb](http://localhost:9292/gitorious/blob/master:app/models/repository.rb)
to view Gitorious blobs.
