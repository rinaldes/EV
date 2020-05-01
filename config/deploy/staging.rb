set :domain, "deploy@188.166.210.238"
role :web, domain
role :app, domain
role :db,  domain, :primary => true

set :deploy_to, "/home/deploy/projects/event-management/"
set :branch, 'develop'
set :rails_env, 'staging'

require "rvm/capistrano"
set :rvm_ruby_string, 'ruby-2.2.2@event-management'
set :rvm_type, :user

# Start and stop server staging
namespace :rails do
#   desc 'stop think rails server'
#   task :stop do
#     run "kill -9 $(cat #{current_path}/tmp/pids/thin.pid)"
#   end

#   desc 'start thin rails server'
#   task :start do
#     run "cd #{current_path} && thin -p 3074 -e #{self.stage}  -d start"
#   end

#   desc 'stop sidekiq server'
#   task :sidekiq_stop do
#     run "kill -9 $(cat #{current_path}/tmp/pids/sidekiq.pid)"
#   end
  
#   desc "start sidekiq server"
#   task :sidekiq do
#     run "cd #{current_path}; RAILS_ENV=#{self.stage} bundle exec sidekiq -d"
#   end
end

namespace :deploy do
  desc "Run bundle install and ensure all gem requirements are met"
  task :bundle do
    run "cd #{current_path} && bundle install --without=test development"
  end
end
