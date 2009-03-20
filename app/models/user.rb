# == Schema Information
# Schema version: 20090319165641
#
# Table name: users
#
#  id                        :integer(4)    not null, primary key
#  openid_url                :string(255)   
#  login                     :string(255)   
#  created_at                :datetime      
#  updated_at                :datetime      
#  remember_token            :string(40)    
#  remember_token_expires_at :datetime      
#  default_format            :string(255)   
#

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByCookieToken
  
  has_many :reminders
  has_friendly_id :login

  validates_presence_of :login
  validates_format_of :login, :with => Authentication.login_regex
  validates_uniqueness_of :openid_url
  validates_uniqueness_of :login, :on => :update

  attr_accessible :openid_url, :login, :default_format
  
  def self.unique_nickname(nickname=nil)
    if nickname.to_s.blank? || !(Authentication.login_regex =~ nickname.to_s)
      nickname = "anonymous_#{rand(1000000)}"
    end
    if User.find_by_login(nickname)
      return unique_nickname("#{nickname}_#{rand(1000000)}")
    end
    return nickname
  end
  
  def remember_me
    remember_me_for 1.year
  end
end
