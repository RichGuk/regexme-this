set :application, "regexme-this"
set :repository, "git://github.com/RichGuk/regexme-this.git"

set :deploy_to, "~/apps/#{application}"

set :scm, :git
set :git_shallow_clone, 1
set :git_enable_submodules, 1
set :deploy_via, :remote_cache
set :branch, 'master'
set :repository_cache, "#{application}-src"
set :key_relesaes, 3
set :use_sudo, false
# set :ssh_options, :forward_agent => true

set :user, 'rich'

role :app, "regexme-this.27smiles.com"
role :web, "regexme-this.27smiles.com"
role :db, "regexme-this.27smiles.com", :primary => true

set :closure, "java -jar ~/sandbox/closure/compiler.jar"

after "deploy:finalize_update", "minify:javascript"
after "deploy:symlink", "deploy:symlinklog"

namespace :deploy do
  desc "restart passenger app"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc 'symlink log directory'
  task :symlinklog do
    run "rm -r #{current_path}/log"
    run "ln -s #{shared_path}/log #{current_path}/log"
  end
end

namespace :minify do
  desc "Minifies javascript"
  task :javascript, :roles => :app do
    path = "#{latest_release}/public/javascripts"
    run "#{closure} --js #{path}/application.js --js_output_file #{path}/application.min.js"
  end
end