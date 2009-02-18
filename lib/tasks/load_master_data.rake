require 'active_record'
require 'active_record/fixtures'
require 'yaml'

namespace :db do
  desc "loading master data"
  task :load_master do
    conf = YAML::load(IO.read(File.join(RAILS_ROOT, "config/database.yml")))
    ActiveRecord::Base.establish_connection(conf[RAILS_ENV])
    if ENV["table"]
      Fixtures.create_fixtures("db/master_fixtures", ENV["table"])
    else
      Dir.glob(File.join(RAILS_ROOT, 'test', 'master_fixtures', '*.yml')).each do |fixture_file|
        Fixtures.create_fixtures('db/master_fixtures', File.basename(fixture_file, '.*'))
      end
    end	
  end
end
