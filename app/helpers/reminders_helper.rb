module RemindersHelper
  include TagsHelper

  def action_path(action, options={})
    return {:user => (params["user"] || @user.login), :controller => :reminders, :action => action}.merge(options)
  end

  def current_tag(action_name)
    return "current-menu"  if params["action"] == action_name
  end
end
