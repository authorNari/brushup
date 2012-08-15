# -*- coding: utf-8 -*-
class RemindersController < ApplicationController
  before_filter :login_required, :only => %w(new create destroy edit update check copy)
  before_filter :same_login_user_required, :only => %w(create destroy edit update check)
  before_filter :save_current_list, :only => %w(today completed list search)

  before_filter :add_crumb_list_action, :only => %w(show confirm_update confirm_create edit new create update)
  before_filter :add_crumb_show_action, :only => %w(confirm_update edit create update)
  before_filter :add_crumb_create_action, :only => %w(confirm_create)
  before_filter :add_crumb_update_action, :only => %w(confirm_update)
  before_filter :add_crumb_current_action_with_tag, :only => %w(list today completed index search)
  before_filter :add_crumb_current_action, :except => %w(list today completed index search)

  helper :reminders
  helper_method :reminder_user
  
  def index
    user = params["user"] || reminder_user.login
    redirect_to "/#{user}/today"
  end

  def show
    @reminder = Reminder.find(params[:id])
  end
  alias :confirm_create :show
  alias :confirm_update :show
  
  def new
    @reminder = Reminder.new
  end

  def edit
    @reminder = Reminder.find(params[:id])
  end

  def create
    @reminder = Reminder.new(params[:reminder])
    @reminder.user_id = current_user.id

    if @reminder.valid?
      @reminder.save_with_update_user!
    
      return render(:template => "/share/autoclose") if view_context.bookmarklet_window?
      flash[:notice] = I18n.t(:created_success, :model => Reminder.model_name.human, :scope => [:notice])
      redirect_to(:action => :confirm_create, :id => @reminder.id, :user => current_user.login)
    else
      logger.debug "DEBUG(create): @reminder = <#{@reminder.to_yaml}>"
      render(:user => current_user.login, :action => "new")
    end
  rescue ActiveRecord::ActiveRecordError => ex
    logger.error "ERROR(create): ex = <#{ex.inspect}>"
    render(:user => current_user.login, :action => "new")
  end

  def update
    @reminder = Reminder.find(params[:id])

    @reminder.attributes = params[:reminder]

    if @reminder.valid?
      @reminder.save_with_update_user!
      
      flash[:notice] = I18n.t(:updated_success, :model => Reminder.model_name.human, :scope => [:notice])
      redirect_to(:action => :confirm_update, :id => @reminder.id, :user => current_user.login)
    else
      logger.debug "DEBUG(update): @reminder = <#{@reminder.to_yaml}>"
      render(:user => current_user.login, :action => "edit")
    end
  rescue ActiveRecord::ActiveRecordError => ex
    logger.error "ERROR(create): ex = <#{ex.inspect}>"
    render(:user => current_user.login, :action => "edit")
  end

  def destroy
    @reminder = Reminder.find(params[:id])
    @reminder.destroy

    redirect_to(view_context.back_list_path)
  end

  def today
    @show_reminder_detail = true
    @reminders = Reminder.todays(:user_id => reminder_user.id, :tag => params["tag"])
    list
  end

  def completed
    @reminders = Reminder.completeds(:user_id => reminder_user.id, :tag => params["tag"])
    list
  end

  def list
    @reminder = Reminder.new(params[:reminder])
    @reminders ||= Reminder.lists(:user_id => reminder_user.id, :tag => params["tag"])
    if @reminder.search_word
      @reminders = @reminders.search(@reminder.search_word)
    end
    @tags = Reminder.all_tag_counts(tagging_conditions: ["reminders.id IN (?)", @reminders.map(&:id)])
    @reminders = @reminders.paginate(:page => params[:page])
    logger.debug{ "DEBUG(reminders#list) : @reminders = <#{@reminders.inspect}>" }

    respond_to do |format|
      format.html { render :action => :index }
      format.rss {
        render :action => :rss, :formats => [:xml], :layout => false
      }
    end
  end

  def copy
    reminder = Reminder.find(params[:id])
    if reminder.deep_clone(current_user).save
      flash[:notice] = I18n.t(:copyed_success, :model => Reminder.model_name.human, :scope => :notice)
    else
      flash[:error] = I18n.t(:copyed_fail, :model => Reminder.model_name.human, :scope => :error)
      logger.error "reminders#copy: #{reminder.errors.inspect}"
    end
    redirect_to :user => current_user.login, :action => :list
  end

  def check
    @reminder = Reminder.find(params[:id])
    
    if @reminder && @reminder.update_learned!
      @show_reminder_detail = true
      respond_to do |format|
        format.html { index }
        format.js { render :check }
      end
    end
  end

  def reminder_user
    if params[:user]
      return @reminder_user ||= User.find(params[:user])
    end
    current_user
  end
  
  private
  def save_current_list
    session[:list_referer] = {
      :controller => controller_name,
      :user => params[:user],
      :action => params[:action],
      :id => params[:id],
      :tag => params[:tag],
    }
  end
  
  def same_login_user_required
    unless current_user?
      flash[:notice] = t("permission_denied", :scope => :notice)
      access_denied
    end
  end
end
