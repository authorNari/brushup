# == Schema Information
# Schema version: 20090118140308
#
# Table name: schedules
#
#  id         :integer       not null, primary key
#  level      :integer       
#  span       :integer       
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
