require 'active_record'
require 'active_record/fixtures'
require 'yaml'

namespace :db do
  desc "loading master data"
  task :load_master do
    conf = YAML::load(IO.read(File.join(RAILS_ROOT, "config/database.yml")))
    ActiveRecord::Base.establish_connection(conf[RAILS_ENV])
    Fixtures.create_fixtures("db/master_fixtures", :schedules)
  end
end
