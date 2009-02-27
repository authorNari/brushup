module RemindersHelper
  def current_tag(action_name)
    return "current-menu"  if params["action"] == action_name
  end

  def tag_cloud_styles
    return %w(tag-light tag-normal tag-many tag-very-many)
  end

  def title_tag_prefix
    return h("/ #{params['tag']}(#{@reminders.size})") if params["tag"]
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
end
