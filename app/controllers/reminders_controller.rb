class RemindersController < ApplicationController
  before_filter :set_user
  before_filter :authorize, :only => %w(new create destroy edit update check)
  before_filter :set_jumpto

  def index
    redirect_to(:action => :today, :user => (params["user"] || @user.login))
  end

  def show
    @reminder = Reminder.find(params[:id])
  end

  def new
    @reminder = Reminder.new
  end

  def edit
    @reminder = Reminder.find(params[:id])
  end

  def create
    @reminder = Reminder.new(params[:reminder].merge!(:user_id => @user.id))

    if @reminder.save
      flash[:notice] = I18n.t(:created_success, :model => Reminder.human_name, :scope => [:notice])
      return render(:template => "/share/autoclose") if params[:mode] == "confirm"
      redirect_to(:action => :list, :user => @user.login) 
    else
      logger.debug "DEBUG(create): @reminder = <#{@reminder.to_yaml}>"
      render(:user => @user.login, :action => "new")
    end
  end

  def update
    @reminder = Reminder.find(params[:id])

    if @reminder.update_attributes(params[:reminder])
      flash[:notice] = I18n.t(:updated_success, :model => Reminder.human_name, :scope => [:notice])
      redirect_to(:action => :list, :user => @user.login)
    else
      logger.debug "DEBUG(update): @reminder = <#{@reminder.to_yaml}>"
      render(:user => @user.login, :action => "edit")
    end
  end

  def destroy
    @reminder = Reminder.find(params[:id])
    @reminder.destroy

    redirect_to(:action => :list, :user => @user.login)
  end

  def today
    @reminders = Reminder.todays(@user.id, params["tag"]).paginate(:page => params[:page])
    list
  end

  def completed
    @reminders = Reminder.completeds(@user.id, params["tag"]).paginate(:page => params[:page])
    list
  end

  def list
    @reminders ||=  Reminder.lists(@user.id, params["tag"]).paginate(:page => params[:page])
    logger.debug "DEBUG(list) : @reminders = <#{@reminders.to_yaml}>"
    @tags = tag_counts(@reminders)

    respond_to do |format|
      format.html { render :action => :index }
      format.rss { render :action => :rss }
    end
  end

  def check
    reminder = Reminder.find(params[:id])
    if reminder && reminder.update_learned!
      render :update do |page|
        page.replace "reminder_#{params[:id]}", (render :partial => "reminder", :locals => {:reminder => reminder})
        page.replace "reminders_check_#{params[:id]}", t(:check_ok, :scope => [:controller, :reminders])
        page.visual_effect :highlight, "reminder_#{params[:id]}"
        page.visual_effect :fade, "reminder_#{params[:id]}"
      end
    end
  end

  private
  def tag_counts(reminders)
    tags = {}
    reminders.each{|r| r.tag_counts.each{|t| tags[t.name] ||= []; tags[t.name] << t }}
    return tags.values
  end
end
