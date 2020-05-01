require 'capistrano/ext/multistage'

set :application, "event-management"
set :stages, %w(staging)
set :default_stage, 'staging'
set :use_sudo, false
set :scm, :git
set :scm_verbose, true
set :keep_releases, 5
set :repository, 'git@bitbucket.org:resha/event-management.git'
set :deploy_via, :remote_cache
set :normalize_asset_timestamps, false

namespace :deploy do

  desc "Run precompile assets"
  task :precompile do
    run "cd #{current_path} && bundle exec rake assets:precompile RAILS_ENV=#{self.stage} --trace"
  end

  desc "Create symlinks database.yml "
  task :link_db do
    db_config = "#{shared_path}/config/database.yml"
    run "rm -rf #{release_path}/config/database.yml"
    run "ln -nsf #{db_config} #{release_path}/config/database.yml"
  end

  desc "Run pending migrations on already deployed code"
  task :migrate do
    run "cd #{current_path}; RAILS_ENV=#{self.stage} bundle exec rake db:migrate --trace"
  end
end

namespace :db do
 desc "Truncate all table and re-seed"
  task :reset do
    run "cd #{current_path}; rake db:truncate db:seed RAILS_ENV=#{self.stage}"
  end
end

after "deploy", "deploy:link_db"
before "deploy:restart", "deploy:bundle"
after "deploy", "deploy:migrate"
after "deploy", "deploy:precompile"
after "deploy", "deploy:cleanup"

after "rails:start", "rails:sidekiq"
after "rails:stop", "rails:sidekiq_stop"

# Symlinks
after  'deploy', 'symlinks:uploads'
namespace :symlinks do
  desc "Create sysmlinks for public/uploads directory"
  task :uploads do
    uploads = "#{shared_path}/public/uploads"
    run "rm -rf #{release_path}/public/uploads"
    run "ln -nsf #{uploads} #{release_path}/public/uploads"
  end
end

