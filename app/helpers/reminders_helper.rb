module RemindersHelper
  def check_link(reminder)
    if reminder.today_remind? && current_user?
      return link_to_remote(t(:check, :scope => [:railties, :scaffold]), :url => {:action => :check, :id => reminder.id})
    end
  end

  def confirm_mode?
    return bookmarklet_window?
  end

  def auto_complete_for_tag(field)
    if bookmarklet_window?
      field.text_field :tag_list
    else
      brushup_text_field_with_auto_complete(field, :tag_list,
                                            {:autocomplete => "off"}, 
                                            {:param_name => 'tag[name]', :method => 'get', :tokens => ['　',' ']})
    end
  end

  def button_for_back_list(options={})
    return button_to(t(options[:action], :scope => [:controller, controller_name]), options) unless options.empty?
    return button_to(t(back_list_path[:action], :scope => [:controller, controller_name]), back_list_path)
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
end
