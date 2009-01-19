# == Schema Information
# Schema version: 20090118140308
#
# Table name: users
#
#  id         :integer       not null, primary key
#  openid_url :string(255)   
#  login      :string(255)   
#  created_at :datetime      
#  updated_at :datetime      
#

class User < ActiveRecord::Base
  has_many :reminders
  has_friendly_id :login
end
