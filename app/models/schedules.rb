# == Schema Information
# Schema version: 20081217131456
#
# Table name: schedules
#
#  id         :integer       not null, primary key
#  level      :integer       
#  span       :integer       
#  created_at :datetime      
#  updated_at :datetime      
#

class Schedules < ActiveRecord::Base
end
