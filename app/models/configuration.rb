# == Schema Information
# Schema version: 20090308015337
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

# -*- coding: utf-8 -*-
# システム全体の設定を表現する。
class Configuration < ActiveRecord::Base
  # システム全体の設定のインスタンスはひとつであることを想定しているた
  # め、IDが1のものを取得して使用する。
  def self.instance
    return find(1)
  end
end
