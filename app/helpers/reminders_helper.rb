module RemindersHelper
  def current_tag(action_name)
    return "current-menu"  if params["action"] == action_name
  end

  def tag_cloud_styles
    return %w(tag-light tag-normal tag-many tag-very-many)
  end

  def title_tag_prefix(tag=nil)
    tag = params["tag"] || tag
    return h("/ #{tag}(#{@reminders.size})") if tag
  end
  
  def tag_cloud(tags, classes)
    return if tags.empty?
    
    max_count = tags.sort_by(&:size).last.size.to_f
    
    tags.each do |tag|
      index = ((tag.size / max_count) * (classes.size - 1)).round
      yield tag.first, classes[index]
    end
  end

  def check_link(reminder)
    if reminder.today_remind? && current_user?
      return link_to_remote(t(:check, :scope => [:railties, :scaffold]), :url => {:action => :check, :id => reminder.id})
    end
  end

  def hidden_reminder_detail
    unless @show_reminder_detail
      return "style='display:none;'"
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

  def rss_title
    if params[:tag]
      "#{t(params[:action], :scope => [:controller, controller_name])}/#{params[:tag]} - #{@user.login}"
    else
      "#{t(params[:action], :scope => [:controller, controller_name])} - #{@user.login}"
    end
  end

  def rss_reminder_pubDate(reminder)
    return reminder.updated_at.to_formatted_s(:rfc822) if params[:action] == "today"
    return reminder.created_at.gmtime.to_formatted_s(:rfc822)
  end

  def rss_reminder_title(reminder)
    title = reminder.title
    return "#{title} (#{t(:to_complete_count, :scope => :text, :count => reminder.to_complete_count)})" if params[:action] == "today"
    return title
  end
end
