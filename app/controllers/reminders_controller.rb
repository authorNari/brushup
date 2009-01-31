class RemindersController < ApplicationController
  before_filter :authorize, :except => %w(index today list completed show check)
  before_filter :set_user, :except => %w(check)
  before_filter :set_jumpto

  # GET /reminders
  def index
    redirect_to(:action => :today, :user => (params["user"] || @user.login))
  end

  # GET /reminders/1
  def show
    @reminder = Reminder.find(params[:id])
  end

  # GET /reminders/new
  def new
    @reminder = Reminder.new
  end

  # GET /reminders/1/edit
  def edit
    @reminder = Reminder.find(params[:id])
  end

  # POST /reminders
  def create
    @reminder = Reminder.new(params[:reminder].merge!(:user_id => @user.id))

    if @reminder.save
      flash[:notice] = I18n.t(:created_success, :model => Reminder.human_name, :scope => [:notice])
      redirect_to(:action => :list, :user => @user.login)
    else
      logger.debug "DEBUG(create): @reminder = <#{@reminder.to_yaml}>"
      render(:user => @user.login, :action => "new")
    end
  end

  # PUT /reminders/1
  def update
    @reminder = Reminder.find(params[:id])

    if @reminder.update_attributes(params[:reminder])
      flash[:notice] = I18n.t(:updated_success, :model => Reminder.human_name, :scope => [:notice])
      redirect_to(:action => :list, :user => @user.login)
    else
      logger.debug "DEBUG(update): @reminder = <#{@reminder.to_yaml}>"
      render(:user => @user.login, :action => "new")
    end
  end

  # DELETE /reminders/1
  def destroy
    @reminder = Reminder.find(params[:id])
    @reminder.destroy

    redirect_to(:action => :list, :user => @user.login)
  end

  def today
    @reminders = Reminder.todays(@user.id, params["tag"])
    list
  end

  def completed
    @reminders = Reminder.completeds(@user.id, params["tag"])
    list
  end

  def list
    @reminders ||=  Reminder.list(@user.id, params["tag"])
    @tags = tag_counts(@reminders)

    respond_to do |format|
      format.html { render :action => :index}
      format.js do
        render :update do |page|
          page['reminder'].reload 
        end
      end
      format.rss { render :action => :rss }
    end
  end

  def check
    @reminder = Reminder.find(params[:id])
    if @reminder && @reminder.update_learned!
      render :update do |page|
        page.replace "reminders_check_#{@reminder.id}", t(:check_ok, :scope => [:controller, :reminders])
      end
    end
  end

  private
  def tag_counts(reminders)
    tags = {}
    reminders.each{|r| r.tag_counts.each{|t| tags[t.name] ||= []; tags[t.name] << t }}
    return tags.values
  end
  
  def get_user_id(id)
    user_id = current_user.id unless id
    user_id ||= User.find(id).id
  end
end
