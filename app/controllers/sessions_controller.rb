class SessionsController < ApplicationController
  before_filter :authorize, :except => %w(index new create authenticate destroy)

  def index
    @user = session[:user_id] if session[:user_id]
  end
  
  def create
    if using_open_id?
      authenticate
    else
      redirect_to sessions_path
    end
  end
  
  def edit
    @user = session[:user_id]
  end
  
  def update
    @user = User.find(session[:user_id].id)
    if @user.update_attributes(params[:edit_user])
      session[:user_id] = @user
      return success_login
    end
    render :action => :edit
  end

  def destroy
    session[:user_id] = nil
    redirect_to openid_path
  end

  protected
  def authenticate(identity_url = "")
    if RAILS_ENV == "development" || RAILS_ENV == "test"
      after_autenticate(true, params[:openid_url], "OK", :nickname => "hoge")
    else
      authenticate_with_open_id(params[:openid_url], :require => [:email, :nickname]) do |result, identity_url, registration|
        after_autenticate(result.successful?, identity_url, result.message, :nickname => registration.nickname)
      end
    end
  end

  private
  def setup_user(identity_url, registration)
    @user = User.new(:openid_url => identity_url)
    @user.login = unique_nickname(registration[:nickname])
    @user.save!
    session[:user_id] = @user
    return @user
  end

  def after_autenticate(successful, identity_url, message, registration={})
    if successful
      @user = User.find_by_openid_url(identity_url)
      unless @user
        return redirect_to(:action => :edit, :user => setup_user(identity_url, registration).id)
      end
      success_login
    else
      flash[:error] = message
      redirect_to :action => "index"
    end
  end

  def success_login
    session[:user_id] = @user
    redirect_to(:controller => "reminders", :user => @user.login, :action => :today)
  end

  def unique_nickname(nickname)
    if User.find_by_login(nickname)
      return unique_nickname("#{nickname}_#{rand(1000)}")
    end
    return nickname
  end
end
