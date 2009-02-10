task :rcov do
   sh "rcov -I./test --rails test/*/*_test.rb"
end

namespace :test do
  namespace :coverage do
    desc "Delete coverage files"
    task :clean do
      rm_rf "coverage"
    end
  end
  desc "Generage coverage files"
  task :coverage => "test:coverage:clean" do
    sh "rcov -I./test --rails test/*/*_test.rb test/*/*/*_test.rb"
  end
end
