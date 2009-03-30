# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include OpenIdAuthenticationToI18n

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  secret_path = File.join(RAILS_ROOT, "config/secret.txt")
  if File.exist?(secret_path)
    secret = open(secret_path) { |io| io.read }.gsub(/\s/, '')
  end
  if !secret || secret.empty?
    characters = ("0".."9").to_a + ("a".."f").to_a
    secret = Array.new(128) { characters[rand(characters.size)] }.join
    open(secret_path, "w") { |io| io.write(secret) }
  end

  protect_from_forgery :secret => secret
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  I18n.default_locale = "ja"

  session :session_expires_after => 1.year
  expires_session :time => 30.days

  helper_method :message_of_user
  before_filter :notice_today_reminder
  
  private
  def on_session_expiry
    flash[:notice] = t(:session_expired, :scope => %w(notice))
  end
  
  def local_request?
    false
  end
  
  def rescue_action_in_public(exception)
    case exception
    when ::ActionController::RoutingError, ::ActionController::UnknownAction, ::ActiveRecord::RecordNotFound
      render :file=>"#{RAILS_ROOT}/public/404.html", :status=>'404 Not Found'
    else
      render :file=>"#{RAILS_ROOT}/public/500.html", :status=>'500 Error'
    end
  end

  def add_crumb_current_action
    add_crumb(ERB::Util.h(t(params[:action], :scope => [:controller, controller_name])))
  end

  def add_crumb_show_action
    add_crumb(t("show", :scope => [:controller, controller_name]), @template.action_path(:show, :id => params[:id]))
  end

  def add_crumb_list_action
    path = @template.back_list_path.dup
    tag = path.delete(:tag)
    add_crumb(message_of_user(path[:action], :scope => [:controller, controller_name]), path)
    add_crumb(ERB::Util.h(tag), @template.back_list_path) if tag
  end
  
  def add_crumb_current_action_with_tag
    path = @template.back_list_path.dup
    tag = path.delete(:tag)
    if tag
      add_crumb(message_of_user(path[:action], :scope => [:controller, controller_name]), path)
      add_crumb(ERB::Util.h(tag))
    else
      add_crumb(message_of_user(path[:action], :scope => [:controller, controller_name]))
    end
  end
  
  def add_crumb_create_action
    add_crumb(t("create", :scope => [:controller, controller_name]), @template.action_path(:new))
  end
  
  def add_crumb_update_action
    add_crumb(t("update", :scope => [:controller, controller_name]), @template.action_path(:edit, :id => params[:id]))
  end

  def message_of_user(id, options={})
    if params[:user] && !(params[:user].empty?)
      return ERB::Util.h(I18n.t(:of_user, :scope => :text, :user => ERB::Util.h(params[:user])) +
        I18n.t(ERB::Util.h(id), options))
    end
    ERB::Util.h(I18n.t(id, options))
  end

  def notice_today_reminder
    if logged_in?
      size = Reminder.todays(:user_id => current_user.id).size
      if size > 0
        flash[:reminder_notice] = t(:today_reminder, :scope => %w(notice), :cnt => size)
      end
    end
  end
end
