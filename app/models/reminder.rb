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

  cattr_reader :per_page
  @@per_page = 20
  
  validates_presence_of :title, :body
  
  acts_as_taggable
  
  named_scope :user, lambda{|user_id| {:conditions => ["#{table_name}.user_id = ?", user_id]} }
  named_scope :completed, :conditions => {:completed => true}
  named_scope :list, :conditions => ["completed is null OR completed = ?", false]
  named_scope :today, :conditions => ["next_learn_date <= ?", Date.today]
  named_scope :without_today, :conditions => ["next_learn_date > ?", Date.today]
  named_scope :tagged_with, lambda{|tags| find_options_for_find_tagged_with(tags) }
  named_scope :order_by_created, :order => "reminders.created_at DESC"

  def attributes=(params, gard=true)
    super
    self.schedule = Schedule.first_level
    self.next_learn_date = get_next_learn_date(self.schedule)
    self.learned_at = Date.today unless self.learned_at
    self.completed = false unless self.completed
  end

  # get today reminders
  def self.todays(user_id, tag=nil)
    return user(user_id).tagged_with(tag).list.today.order_by_created
  end

  def self.completeds(user_id, tag=nil)
    return user(user_id).tagged_with(tag).completed.order_by_created
  end

  def self.lists(user_id, tag=nil)
    return user(user_id).tagged_with(tag).list.without_today.order_by_created
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

  def to_complete_count
    return (Schedule.count - schedule.level + 1) unless completed
  end

  def tag_list_with_convert=(str)
    str.gsub!("　", " ")
    self.tag_list_without_convert=str
  end
  alias_method_chain :tag_list=, :convert
  
  
  private
  def get_next_learn_date(schedule)
    return Date.today + self.schedule.span
  end
end
