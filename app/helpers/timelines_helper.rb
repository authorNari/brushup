module TimelinesHelper
  def action_path(action, options={})
    return {:controller => :timelines, :action => action, :tag => nil}.merge(options)
  end

  def back_list_path
    return session[:list_referer] ? session[:list_referer] : action_path(:index)
  end
  
  def button_for_back_list
    return button_to(t(back_list_path[:action], :scope => [:controller, controller_name]), back_list_path)
  end
  
  def rss_title
    if params[:tag]
      "#{t(params[:action], :scope => [:controller, controller_name])}/#{params[:tag]}"
    else
      "#{t(params[:action], :scope => [:controller, controller_name])}"
    end
  end
end
