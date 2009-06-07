require 'test_helper'
require 'performance_test_help'

# タイムライン画面の負荷チェックを行います
# 
# ユーザと復習数が増えるにつれて復習のページ表示が耐えられないほど遅く
# なってきました．
class TimelinesTest < ActionController::PerformanceTest
  def setup
    create_performance_test_data
    Rails.logger.level = ActiveSupport::BufferedLogger::DEBUG
  end

  def test_list
    puts "Reminder count #{Reminder.lists.size}"
    puts "Tag count #{Tag.count}"
    get '/timelines/list'
  end

  # def test_user_list
  #   puts "Reminder count #{Reminder.lists.size}"
  #   puts "Tag count #{Tag.count}"
  #   get '/authorNari/list'
  # end

  private
  def create_performance_test_data
    1000.times do |i|
      reminder = Reminder.new(reminders(:list_reminder).attributes)
      reminder.tag_list = "#{rand(i).to_s} #{rand(i).to_s}"
      reminder.save!
    end
  end
end
