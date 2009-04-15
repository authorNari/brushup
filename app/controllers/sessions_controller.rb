class SessionsController < ApplicationController
  before_filter :login_required, :only => %w(edit update)

  def index
    @user = current_user
  end
  
  def create
    if using_open_id?
      logout_keeping_session!
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
    @user = current_user
  end
  
  def update
    @user = User.find(current_user.login)
    if @user.update_attributes(params[:edit_user])
      success_login
      return redirect_to(:controller => "reminders", :user => @user.login, :action => :today)
    end
    render :action => :edit
  end

  def destroy
    logout_killing_session!
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
        success_login
        return redirect_to(:controller => "reminders", :user => @user.login, :action => :today)
      end
      @user = create_user(identity_url, registration)
      success_login
      redirect_to(:action => :edit, :user => @user.login)
    else
      flash[:error] = message
      redirect_to :action => "index"
    end
  end

  def success_login
    self.current_user = @user
    @user.remember_me
    send_remember_cookie!
  end
end
