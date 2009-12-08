set :application, "regexme-this"
set :repository, "git://github.com/RichGuk/regexme-this.git"

set :deploy_to, "~/public_html/#{application}"

set :scm, :git
set :git_shallow_clone, 1
set :git_enable_submodules, 1
set :deploy_via, :remote_cache
set :branch, 'master'
set :repository_cache, "#{application}-src"
set :key_relesaes, 3
set :use_sudo, false
# set :ssh_options, :forward_agent => true

role :app, "regexme-this.27smiles.com"
role :web, "regexme-this.27smiles.com"
role :db, "regexme-this.27smiles.com", :primary => true

namespace :deploy do
  desc "restart passenger app"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end