module TimelinesHelper
  def action_path(action, options={})
    return {:controller => :timelines, :action => action, :tag => nil}.merge(options)
  end

  def link_to_back_list
    link = t(back_list_path[:action], :scope => [:controller, controller_name])
    return link_to(t(:to, :scope => :links, :link => link), back_list_path)
  end
  
  def rss_title
    if params[:tag]
      "#{t(params[:action], :scope => [:controller, controller_name])}/#{params[:tag]}"
    else
      "#{t(params[:action], :scope => [:controller, controller_name])}"
    end
  end
end
