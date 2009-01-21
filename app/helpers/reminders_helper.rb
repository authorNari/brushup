module RemindersHelper
  include TagsHelper

  def action_path(action, params={})
    return {:user => @user.login, :controller => :reminders, :action => action}.merge(params)
  end

  def current_tag(action_name)
    return "current-menu"  if params["action"] == action_name
  end
end
