# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # helper :all # include all helpers, all the time

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
  
  private
  def on_session_expiry
    flash[:notice] = t(:session_expired, :scope => %w(notice))
  end
  
  def authorize
    if !session[:user_id] ||
        !@user ||
        !(same_user = (session[:user_id].id == @user.id))
      logger.debug "DEBUG(authorize) : session = <#{(session[:user_id]&&session[:user_id].to_yaml)}>, user = <#{@user.to_yaml}>"
      flash[:notice] = t("permission_denied", :scope => :notice) unless same_user
      flash[:notice] = t("please_log_in", :scope => :notice) if same_user
      # save the URL the user requested so we can hop back to it
      # after login
      redirect_to(openid_path)
    end
  end

  def set_jumpto
    session[:jumpto] = request.parameters
  end
  
  def set_user
    if params[:user]
      @user = User.find(params[:user])
    elsif session[:user_id]
      @user = session[:user_id]
      params[:user] = @user.login
    end
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
    add_crumb( h(t(params[:action], :scope => [:controller, controller_name])))
  end
end
