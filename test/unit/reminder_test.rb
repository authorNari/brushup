require File.join(File.dirname(__FILE__), '../test_helper')

class ReminderTest < ActiveSupport::TestCase
  test "should todays" do
    size =
      Reminder.find(:all,
                    :conditions => ["next_learn_date <= ? AND (completed is null OR completed = ?) AND user_id = ?",
                                    Date.today, false, users(:nari).id]).size
    
    assert_equal size, Reminder.todays(users(:nari).id).size
  end

  test "should completeds" do
    size =
      Reminder.find(:all,
                    :conditions => ["completed = ? AND user_id = ?",
                                    true, users(:nari).id]).size
    
    assert_equal size, Reminder.completeds(users(:nari).id).size
  end
  
  test "should lists" do
    size =
      Reminder.find(:all,
                    :conditions =>
                    ["(completed is null OR completed = ?) AND user_id = ?",
                     false, users(:nari).id]).size
    
    assert_equal size, Reminder.lists(users(:nari).id).size
  end
  
  test "should lists with tags" do
    reminders(:learned_remined_1).tag_list = "fuge hoge"
    reminders(:learned_remined_1).save!
    size =
      Reminder.find_tagged_with("fuge",
                                :conditions =>
                                ["(completed is null OR completed = ?) AND user_id = ?",
                                 false, users(:nari).id]).size
    assert_equal size, Reminder.lists(users(:nari).id, "fuge").size
  end
  
  test "should update learned" do
    reminders(:learned_remined_1).update_learned!
    assert_equal 2, reminders(:learned_remined_1).schedule.level
    assert_equal reminders(:learned_remined_1).next_learn_date, Date.today + schedules(:level_2).span
  end

  test "should update learned with complete" do
    reminders(:next_level_complete_remind).update_learned!
    assert_equal true, reminders(:next_level_complete_remind).completed
    assert_nil reminders(:next_level_complete_remind).next_learn_date
  end

  test "should attributes" do
    r = Reminder.new(:title => "hoge")
    assert_not_nil r.schedule
    assert_not_nil r.next_learn_date
  end
  
  test "should to complete count with completed" do
    assert_nil reminders(:completed_reminder).to_complete_count
  end

  test "should to complete count" do
    assert_equal 3, reminders(:level_2_reminder).to_complete_count
  end
  
  test "should tag lists with convert" do
    reminders(:level_2_reminder).tag_list = "hoge　fuge"
    assert_equal 2, reminders(:level_2_reminder).tag_list.size
  end
end
