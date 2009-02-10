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

  validates_presence_of :title, :body
  
  acts_as_taggable

  def attributes=(params, gard=true)
    super
    self.schedule = Schedule.first_level
    self.next_learn_date = get_next_learn_date(self.schedule)
    self.learned_at = Date.today unless self.learned_at
    self.completed = false unless self.completed
  end

  # get today reminders
  def self.todays(user_id, tag=nil)
    return find_or_find_tagged_with(
            find_options(:conditions =>
                         ["next_learn_date <= ? AND (completed is null OR completed = ?) AND user_id = ?",
                          Date.today,
                          false,
                          user_id]),
           tag)
  end

  def self.completeds(user_id, tag=nil)
    return find_or_find_tagged_with(find_options(:conditions => {:completed => true, :user_id => user_id}), tag)
  end

  def self.list(user_id, tag=nil)
    return find_or_find_tagged_with(find_options(:conditions => {:user_id => user_id}), tag)
  end
  
  def today_remind?
    return (self.next_learn_date && self.next_learn_date <= Date.today && !self.completed)
  end
  
  def update_learned!
    self.learned_at = Date.today
    if self.schedule.next_level
      self.schedule = schedule.next_level
      self.next_learn_date = get_next_learn_date(self.schedule)
    else
      self.completed = true
      self.schedule = nil
      self.next_learn_date = nil
    end
    save!
  end

  private
  def get_next_learn_date(schedule)
    return Date.today + self.schedule.span
  end

  def self.find_options(options)
    return options.merge(:order => "'created_at' DESC")
  end

  def self.find_or_find_tagged_with(options, tag=nil)
    return find(:all, options) unless tag
    return find_tagged_with(tag, options)
  end
end
