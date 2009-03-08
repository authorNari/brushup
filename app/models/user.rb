# == Schema Information
# Schema version: 20090308015337
#
# Table name: users
#
#  id         :integer(4)    not null, primary key
#  openid_url :string(255)   
#  login      :string(255)   
#  created_at :datetime      
#  updated_at :datetime      
#

class User < ActiveRecord::Base
  has_many :reminders
  has_friendly_id :login

  @@login_format = /\A\w[\w\.\-_@]+\z/  # ASCII, strict
  
  validates_presence_of :login
  validates_format_of :login, :with => @@login_format
  validates_uniqueness_of :openid_url
  validates_uniqueness_of :login, :on => :update

  attr_accessible :openid_url, :login
  
  def self.unique_nickname(nickname=nil)
    if nickname.to_s.blank? || !(@@login_format =~ nickname.to_s)
      nickname = "anonymous_#{rand(1000000)}"
    end
    if User.find_by_login(nickname)
      return unique_nickname("#{nickname}_#{rand(1000000)}")
    end
    return nickname
  end
end
