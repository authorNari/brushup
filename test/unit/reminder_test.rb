require File.join(File.dirname(__FILE__), '../test_helper')

class ReminderTest < ActiveSupport::TestCase
  test "should todays truth" do
    size =
      Reminder.find(:all,
                    :conditions => ["next_learn_date <= ? AND (completed is null OR completed = ?) AND user_id = ?",
                    Date.today, false, users(:nari).id]).size
    assert_equal size, Reminder.todays(users(:nari).id).size
  end

  test "should update learned truth" do
    reminders(:learned_remined_1).update_learned!
    assert_equal 2, reminders(:learned_remined_1).schedule.level
    assert_equal reminders(:learned_remined_1).next_learn_date, Date.today + schedules(:level_2).span
  end

  test "should update learned with complete" do
    reminders(:next_level_complete_remind).update_learned!
    assert_equal true, reminders(:next_level_complete_remind).completed
    assert_nil reminders(:next_level_complete_remind).next_learn_date
  end

  test "should attributes truth" do
    r = Reminder.new(:title => "hoge")
    assert_not_nil r.schedule
    assert_not_nil r.next_learn_date
  end
end
