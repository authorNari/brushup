class SessionsController < ApplicationController
  def new
  end

  def create
    if using_open_id?
      authenticate
    else
      redirect_to sessions_path
    end
  end

  def update
    @user = User.find(params[:id])
    @user.update_attributes(params[:user])
    session[:user_id] = @user
    success_login
  end

  def destroy
    session[:user_id] = nil
    redirect_to session[:jumpto]
  end

  protected
  def authenticate(identity_url = "")
    if RAILS_ENV == "development"
      after_autenticate(true, params[:openid_url], "OK", :nickname => "hoge")
    else
      authenticate_with_open_id(params[:openid_url], :require => [:email, :nickname]) do |result, identity_url, registration|
        after_autenticate(result.successful?, identity_url, result.message, :nickname => registration.nickname)
      end
    end
  end

  def root_url
    openid_url
  end

  private
  def setup_user(identity_url, registration)
    @user = User.new(:openid_url => identity_url)
    @user.save!
    @user.login = registration[:nickname]
    return @user
  end

  def after_autenticate(successful, identity_url, message, registration={})
    if successful
      @user = User.find_by_openid_url(identity_url)
      return redirect_to(edit_session_path(:id => setup_user(identity_url, registration).id)) unless @user
      return redirect_to(edit_session_path(:id => @user.id)) unless @user.login
      success_login
    else
      flash[:error] = message
      redirect_to :action => "index"
    end
  end

  def success_login
    session[:user_id] = @user

    jumpto = session[:jumpto] || { :controller => "reminders", :user => @user.login }
    session[:jumpto] = nil
    redirect_to(jumpto)
  end
end
