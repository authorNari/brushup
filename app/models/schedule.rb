# == Schema Information
# Schema version: 20090308015337
#
# Table name: schedules
#
#  id         :integer(4)    not null, primary key
#  level      :integer(4)    
#  span       :integer(4)    
#  created_at :datetime      
#  updated_at :datetime      
#

class Schedule < ActiveRecord::Base
  has_many :reminders

  def next_level
    return Schedule.find_by_level(level.succ)
  end

  def self.first_level
    return Schedule.find(:first, :order => :level)
  end
end
