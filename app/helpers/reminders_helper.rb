# -*- coding: utf-8 -*-
module RemindersHelper
  def check_link(reminder)
    if reminder.today_remind? && current_user?
      return link_to(t(:check, :scope => [:railties, :scaffold]), {:action => :check, :id => reminder.id, :user => current_user.login}, remote: true, method: :get)
    end
  end

  def confirm_mode?
    return bookmarklet_window?
  end

  def link_to_back_list(options={})
    options = back_list_path if options.empty?
    link = t(options[:action], :scope => [:controller, controller_name])
    return link_to(t(:to, :scope => :links, :link => link), options) 
  end
  
  def rss_title
    if params[:tag]
      "#{t(params[:action], :scope => [:controller, controller_name])}/#{params[:tag]} - #{reminder_user.login}"
    else
      "#{t(params[:action], :scope => [:controller, controller_name])} - #{reminder_user.login}"
    end
  end
  
  def back_list_path
    if(session[:list_referer] &&
       session[:list_referer][:controller] == controller_name &&
       session[:list_referer][:user] == params[:user])
      return session[:list_referer]
    end
    return action_path(:index)
  end
  
  def rss_reminder_link(reminder)
    if params[:action] == "today"
      url_for(action_path(:show,
                          :id => reminder.id,
                          :brushup_date => reminder.next_learn_date,
                          :delay => h(Date.today - reminder.next_learn_date),
                          :only_path => false))
    else
      url_for(action_path(:show, :id => reminder.id, :only_path => false))
    end
  end

  def format_selectbox(f, reminder)
    options = {}
    options = {:selected => current_user.default_format} if reminder.new_record?
    f.select(:format,
             Brushup::Formatting.format_types.map{|k| [t(k, :scope => :format_type), k.to_s]},
             options)
  end

  def today_tag_label_link
    label = "#{t(:today, :scope => [:controller, :reminders])}(#{Reminder.todays(:user_id => User.find(params[:user]).id).size})"
    link_to(label, action_path(:today))
  end
end
