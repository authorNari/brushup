class SessionsController < ApplicationController
  before_filter :set_user, :only => %w(edit update destroy)
  before_filter :authorize, :only => %w(edit update destroy)

  def index
    @user = session[:user_id] if session[:user_id]
  end
  
  def create
    if using_open_id?
      authenticate
    else
      redirect_to sessions_path
    end
  rescue ActiveRecord::ActiveRecordError => ex
    logger.error "ERROR: exception =<#{ex.class}> message =<#{ex.message}>"
    flash[:notice] = t(:fail_login, :scope => :notice)
    redirect_to :action => "index"
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
    authenticate_with_open_id(params[:openid_url], :required => [:email, :nickname]) do |result, identity_url, registration|
      after_autenticate(result.successful?, identity_url, result.message, registration)
    end
  end

  private
  def create_user(identity_url, registration)
    user = User.new(:openid_url => identity_url)
    user.login = User.unique_nickname(registration["nickname"])
    user.save!
    return user
  end

  def after_autenticate(successful, identity_url, message, registration={})
    if successful
      if @user = User.find_by_openid_url(identity_url)
        return success_login
      end
      @user = create_user(identity_url, registration)
      session[:user_id] = @user
      redirect_to(:action => :edit, :user => @user.id)
    else
      flash[:error] = message
      redirect_to :action => "index"
    end
  end

  def success_login
    session[:user_id] = @user
    redirect_to(:controller => "reminders", :user => @user.login, :action => :today)
  end
end
