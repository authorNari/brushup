require File.join(File.dirname(__FILE__), '../test_helper')

class ScheduleTest < ActiveSupport::TestCase
  test "next level truth" do
    assert_equal 2, Schedule.find_by_level(1).next_level.level
  end
end
