namespace :db do
  desc "loading master data"
  task :load_master => :environment do
    require 'active_record/fixtures'
    ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
    (ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : Dir.glob(File.join(RAILS_ROOT, 'db', 'master_fixtures', '*.{yml,csv}'))).each do |fixture_file|
      Fixtures.create_fixtures('db/master_fixtures', File.basename(fixture_file, '.*'))
    end
  end
end
