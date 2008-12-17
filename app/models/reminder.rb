# == Schema Information
# Schema version: 20081217131456
#
# Table name: reminders
#
#  id          :integer       not null, primary key
#  user_id     :integer       
#  schedule_id :integer       
#  title       :string(255)   
#  body        :text          
#  public      :boolean       
#  leared      :boolean       
#  created_at  :datetime      
#  updated_at  :datetime      
#

class Reminder < ActiveRecord::Base
end
