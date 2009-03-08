module RemindersHelper
  def check_link(reminder)
    if reminder.today_remind? && current_user?
      return link_to_remote(t(:check, :scope => [:railties, :scaffold]), :url => {:action => :check, :id => reminder.id})
    end
  end

  def confirm_mode? 
    return params[:mode] == "confirm"
  end

  def auto_complete_for_tag(field)
    if confirm_mode?
      field.text_field :tag_list
    else
      brushup_text_field_with_auto_complete(field, :tag_list,
                                            {:autocomplete => "off"}, 
                                            {:param_name => 'tag[name]', :method => 'get', :tokens => ['　',' ']})
    end
  end

  def back_list_path
    return session[:list_referer] ? session[:list_referer] : action_path(:index)
  end
  
  def button_for_back_list
    return button_to(t(back_list_path[:action], :scope => [:controller, controller_name]), back_list_path)
  end
end
