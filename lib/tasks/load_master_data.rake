namespace :db do
  desc "loading master data"
  task :load_master => :environment do
    ENV['FIXTURES_PATH'] = "db/master_fixtures"
    Rake::Task['db:fixtures:load'].execute
  end
end
