# == Schema Information
# Schema version: 20090118140308
#
# Table name: reminders
#
#  id              :integer       not null, primary key
#  user_id         :integer       
#  schedule_id     :integer       
#  title           :string(255)   
#  body            :text          
#  completed       :boolean       
#  learned_at      :date          
#  created_at      :datetime      
#  updated_at      :datetime      
#  next_learn_date :date          
#

class Reminder < ActiveRecord::Base
  belongs_to :user
  belongs_to :schedule
  
  acts_as_taggable

  def attributes=(params, gard=true)
    super
    self.schedule = Schedule.first_level
    self.next_learn_date = get_next_learn_date(self.schedule)
  end

  # get today reminders
  def self.todays(user_id)
    return find(:all, :conditions => ["next_learn_date <= ? AND completed = ? AND user_id = ?", Date.today, false, user_id])
  end

  def self.completeds(user_id)
    return find(:all, :conditions => {:completed => true, :user_id => user_id})
  end

  def today_remind?
    return true if self.next_learn_date && self.next_learn_date <= Date.today && self.completed == false
  end
  
  def update_learned!
    self.learned_at = Date.today
    if self.schedule.next_level
      self.schedule = schedule.next_level
      self.next_learn_date = get_next_learn_date(self.schedule)
    else
      self.schedule = nil
      self.next_learn_date = nil
    end
    save!
  end

  private
  def get_next_learn_date(schedule)
    return Date.today + self.schedule.span
  end
end
