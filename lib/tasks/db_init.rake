namespace :db do
  desc "detabase initialize"
  task :init => :environment do
    Rake::Task["db:migrate"].invoke
    Rake::Task["db:reset"].invoke
  end
end
