# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20090319165641
#
# Table name: configurations
#
#  id               :integer(4)    not null, primary key
#  email            :string(255)   default("brushup@example.com"), not null
#  google_analytics :string(255)   default(""), not null
#  google_adsense   :string(255)   default(""), not null
#  created_at       :datetime      
#  updated_at       :datetime      
#

# システム全体の設定を表現する。
class Configuration < ActiveRecord::Base
  attr_accessible :email, :google_analytics, :google_adsense

  # システム全体の設定のインスタンスはひとつであることを想定している
  def self.instance
    return find(:all).first
  end
end
