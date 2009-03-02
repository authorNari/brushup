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
    expect_rems =
      Reminder.find(:all,
                    :conditions =>
                    ["(completed is null OR completed = ?) AND next_learn_date > ? AND user_id = ?",
                     false, Date.today, users(:nari).id],
                    :order => "created_at DESC")
    
    
    assert_equal expect_rems.size, Reminder.lists(users(:nari).id).size
    target_rems = Reminder.lists(users(:nari).id)
    expect_rems.size.times{|i| assert_equal target_rems[i].id, expect_rems[i].id }
  end
  
  test "should lists with tags" do
    reminders(:list_reminder_with_tag).tag_list = "fuge hoge"
    reminders(:list_reminder_with_tag).save!
    size =
      Reminder.find_tagged_with("fuge",
                                :conditions =>
                                ["(completed is null OR completed = ?) AND next_learn_date > ? AND user_id = ?",
                                 false, Date.today, users(:nari).id]).size
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

  test "should body with formatter" do
    reminders(:level_2_reminder).format = "default"
    reminders(:level_2_reminder).body = "http://hoge"
    assert_equal "<p><a href=\"http://hoge\">http://hoge</a></p>", reminders(:level_2_reminder).body
  end
end
