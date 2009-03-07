namespace :db do
  desc "loading master data"
  task :load_master => :environment do
    require 'active_record/fixtures'
    ActiveRecord::Base.transaction do
      (ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : Dir.glob(File.join(RAILS_ROOT, 'db', 'master_fixtures', '*.{yml,csv}'))).each do |fixture_file|
        tname = File.basename(fixture_file, '.*')
        raise "#{tname} table already inserted columns." unless tname.singularize.camelize.constantize.find(:all).size.zero?
        Fixtures.create_fixtures('db/master_fixtures', tname)
      end
    end
  end
end
