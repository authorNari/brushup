require File.join(File.dirname(__FILE__), '../test_helper')

class ReminderTest < ActiveSupport::TestCase
  test "todays truth" do
    assert_equal 2, Reminder.todays(users(:nari).id).size
  end

  test "update_learned truth" do
    reminders(:learned_remined_1).update_learned!
    assert_equal 2, reminders(:learned_remined_1).schedule.level
    assert_equal reminders(:learned_remined_1).next_learn_date, Date.today + schedules(:level_2).span
  end

  test "attributes truth" do
    r = Reminder.new(:title => "hoge")
    assert_not_nil r.schedule
    assert_not_nil r.next_learn_date
  end
end
