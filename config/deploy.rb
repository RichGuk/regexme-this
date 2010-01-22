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

set :yui_compressor, "/usr/bin/env java -jar /home/rich/sandbox/yuicompressor.jar"

after "deploy:finalize_update", "minify:javascript"
after "deploy:finalize_update", "minify:stylesheet"

namespace :deploy do
  desc "restart passenger app"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

namespace :minify do
  desc "Minifies javascript"
  task :javascript, :roles => :app do
    path = "#{latest_release}/public/javascripts"
    run "#{yui_compressor} --type js #{path}/application.js -o #{path}/application.min.js"
  end

  desc "Minifies stylesheets"
  task :stylesheet, :roles => :app do
    path = "#{latest_release}/public/stylesheets"

    run "#{yui_compressor} --type css #{path}/reset.css -o #{path}/reset.min.css"
    run "#{yui_compressor} --type css #{path}/master.css -o #{path}/master.min.css"
  end
end