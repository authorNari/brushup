module RemindersHelper
  include TagsHelper

  def action_path(action, params={})
    return {:user => @user.login, :controller => :reminders, :action => action}.merge(params)
  end
end
