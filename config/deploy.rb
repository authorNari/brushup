set :application, "brushup"
set :repository,  "git://github.com/takaokouji/brushup.git"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/lib/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :git

set :branch, "master"

set :deploy_via, :export

set :use_sudo, false

default_run_options[:shell] = false

set :user, application
