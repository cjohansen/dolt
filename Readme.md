# Dolt - The Git project browser

Dolt is a stand-alone Git repository browser. It can be used to explore repos in
your browser of choice and features syntax highlighting with
[Pygments](http://pygments.org/),
[Markdown](http://daringfireball.net/projects/markdown/)/[org-mode](http://orgmode.org/)/[+++](https://github.com/github/markup/)
rendering, commit log and blame.

Dolt is also a library, designed to render Git trees, blobs, commit log and
blame. It can render said views with or without a layout, or you can provide
your own templates (through [Tilt](https://github.com/rtomayko/tilt/)). You can
also provide your own rendering implementation to render other formats than
templates outputting HTML.

Dolt is the implementation of the next generation repo browser to be used in the
[Gitorious](http://gitorious.org) software.

## Installing Dolt

To install `dolt` you need Ruby, RubyGems and Python development files. The
Python development files are required to support Pygments syntax highlighting.

### Systems using apt (Debian/Ubuntu, others)

    # 1) Install Ruby (skip if you already have Ruby installed)
    sudo apt-get install ruby

    # 2) Install Python development files
    sudo apt-get install python-dev

    # 3) Install dolt. This may or may not require the use of sudo, depending on
    #    how you installed Ruby.
    sudo gem install dolt

### Systems using yum (Fedora/CentOS/RedHat, others)

    # 1) Install Ruby (skip if you already have Ruby installed)
    sudo yum install ruby

    # 2) Install Python development files
    sudo yum install python-devel

    # 3) Install dolt. This may or may not require the use of sudo, depending on
    #    how you installed Ruby.
    sudo gem install dolt

# The Dolt CLI

The `dolt` library installs a CLI that can be used to quickly browse either a
single (typically the current) repository, or multiple repositories.

## Browsing a single repository

In a git repository, issue the following command:

    $ dolt .

Then open a browser at [http://localhost:3000](http://localhost:3000). You will
be redirected to the root tree, and can browse the repository. To view trees and
blobs at specific refs, use the URL. A branch/tag selector will be added later.

## Browsing multiple repositories

The idea is that eventually, `dolt` should be able to serve up all Git
repositories managed by your Gitorious server. It does not yet do that, because
there currently is no "repository resolver" that understands the hashed paths
Gitorious uses.

Meanwhile, if you have a directory that contains multiple git repositories, you
can browse all of them through the same process by doing:

    $ dolt /path/to/repos

Now [http://localhost:3000/repo](http://localhost:3000/repo) will allow you to
browse the `/path/repos/repo` repository. As `dolt` matures, there will be a
listing of all repositories and more.

# License

Dolt is free software licensed under the
[GNU Affero General Public License (AGPL)](http://www.gnu.org/licenses/agpl-3.0.html).
Dolt is developed as part of the Gitorious project.
