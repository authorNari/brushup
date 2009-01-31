# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def logged_in?
    session[:user_id]
  end

  def current_user?
    logged_in? && session[:user_id].login == params["user"]
  end

  def display_date(date)
    return date.strftime("%Y年%m月%d日")
  end
end
