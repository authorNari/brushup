# == Schema Information
# Schema version: 20090117134249
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
end
