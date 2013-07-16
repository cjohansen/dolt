# Dolt

<a href="http://travis-ci.org/cjohansen/dolt" class="travis">
  <img src="https://secure.travis-ci.org/cjohansen/dolt.png">
</a>

Dolt is a stand-alone Git repository browser. It can be used to explore
repositories in your browser of choice, and features syntax highlighting with
[http://pygments.org/](Pygments) and various markdown formats (see below). In
addition to offering tree and blob browsing, Dolt also supports rendering the
commit log and blame.

## Installation

To install `dolt` you need Ruby, [http://www.rubygems.org/](RubyGems) and
Python development files. The Python development files are required to support
Pygments syntax highlighting.

### Systems using apt (Debian/Ubuntu, others)

```sh
# 1) Install Ruby and RubyGems
sudo apt-get install -y ruby rubygems

# 2) Install Python development files and unicode tools
sudo apt-get install -y python-dev libicu-dev

# 3) Install dolt. This may or may not require the use of sudo, depending on
#    how you installed Ruby.
gem install dolt
```

### Systems using yum (Fedora/CentOS/RedHat, others)

```sh
# 1) Install Ruby and RubyGems
sudo yum install -y ruby rubygems

# 2) Install Python development files and unicode tools
sudo yum install -y python-devel libicu-devel

# 3) Install dolt. This may or may not require the use of sudo, depending on
#    how you installed Ruby.
gem install dolt
```

## The `dolt` Command Line Interface

Dolt installs a binary, aptly named `dolt` on your system. This binary has only
one required argument, the directory to serve repositories from. To try it out,
simply enter a git repository from your terminal and enter

```sh
dolt .
```

This will start a dolt instance serving your current repository on
[http://localhost:3000/](port 3000).

Dolt will serve either a single repository, like above, or a directory of git
repositories. Let's say you have a directory `/home/dolt/repositories`
containing a collection of bare Git repositories you push your work to over SSH.
To serve all of these over the web, simply:

```sh
cd /home/dolt/repositories
dolt .
```

And you'll be presented with a list of the repositories you can browse.

The `dolt` binary supports a number of options, which can be listed using the
`--help` switch. The following options are currently supported:

* `--socket` lets you specify a UNIX socket to listen to instead of a port.
     Enter the path to a socket.
* `--port` lets you specify a different port than 3000. Also supported through
     the environment variable `PORT`.
* `--bind` lets you bind to a different IP address than `0.0.0.0`. Also
     supported through the environment variable `IP`.
* `--tabwidth` lets you specify how many spaces to use when rendering a tab in a
     source file
* `--pidfile` lets you specify the path to a pid file. Entering this option will
     daemonize the dolt process.
* `--logfile` lets you specify the path to a log file when running daemonized.

Please note that some of the options allowed can also be specified using
environment variables. If no option is given to the CLI, the environment
variable will be used if available, otherwise a default will be used.

To stop a running Dolt server, you'll need to do a little manual work:

```sh
kill `cat /path/to/dolt.pid`
```

A future version of Dolt/Gitorious will support stopping a running dolt server.

## Deploying under "a real" web server

To make your repositories publicly available you could specify `port` as 80.
However, to do this you need to be root on the machine, and it won't work if
you're already running a web server on your computer.

A more practical solution is to have dolt listening on a socket (or port for
that matter), daemonize it, and use your web server as a proxy in front of dolt.

A minimal nginx configuration which lets you do this could look like this
(replace `server_name` with the host name you'll be using):

```conf
upstream dolt {
  server unix://tmp/dolt.sock fail_timeout=30s;
}

server {
  server_name git.zmalltalker.com;
  location / {
    proxy_pass http://dolt;
    proxy_redirect off;
  }
}
```

On Debian/Ubuntu, add this to `/etc/nginx/sites-available/dolt`, symlink this to
`/etc/nginx/sites-enabled/dolt` and reload nginx:

```sh
service nginx reload
```

On CentOS, add the same contents to `/etc/nginx/conf.d/dolt.conf` and reload
nginx:

```sh
service nginx reload
```

## Rendering markup

Dolt uses [https://github.com/github/markup](GitHub Markup) to render
different markup formats. In order to have Dolt render these, you need to
install some different Ruby gems. These gems are not required to install Dolt,
so you'll have to install the ones you need separately.

### Markdown

To render files with suffixes `.markdown`, `.mdown` and `md`, install the
`redcarpet` gem.

```sh
gem install redcarpet
```

### Org-mode

To render [http://org-mode.org/](org-mode) files with a `.org` suffix, you'll
need the `org-ruby` gem installed on your system.

```sh
gem install org-ruby
```

### Textile

Rendering `.textile` files requires the `RedCloth` gem installed on your system.

```sh
gem install RedCloth
```

### Other formats

To render other markup formats, have a look at the
[https://github.com/github/markup](GitHub Markup) page.

## Why dolt?

Dolt is an extraction of the new code browser in
[https://gitorious.org/gitorious/mainline](Gitorious). Setting up a full-blown
Git repository hosting site just to make it possible to show your source code to
the world feels like way too much work with the current situation. You could use
`git instaweb`, but that's ridiculously ugly and only allows serving up a single
repository.

Dolt uses [http://libgit2.github.com](libgit2) for most git operations, and
should perform a lot better than implementations primarily using the git command
line tools to integrate with Git.

## License

Dolt is free software licensed under the
[http://www.gnu.org/licenses/agpl-3.0.html](GNU Affero General Public License
(AGPL)). Dolt is developed as part of the Gitorious project.
