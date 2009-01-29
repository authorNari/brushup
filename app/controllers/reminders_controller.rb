class RemindersController < ApplicationController
  before_filter :authorize, :except => %w(index today list completed show check)
  before_filter :set_user, :except => %w(check)
  before_filter :set_jumpto

  # GET /reminders
  # GET /reminders.xml
  def index
    redirect_to(:action => :today, :user => (params["user"] || @user.login))
  end

  # GET /reminders/1
  # GET /reminders/1.xml
  def show
    @reminder = Reminder.find(params[:id])
  end

  # GET /reminders/new
  # GET /reminders/new.xml
  def new
    @reminder = Reminder.new
  end

  # GET /reminders/1/edit
  def edit
    @reminder = Reminder.find(params[:id])
  end

  # POST /reminders
  # POST /reminders.xml
  def create
    @reminder = Reminder.new(params[:reminder].merge!(:user_id => @user.id))

    if @reminder.save
      flash[:notice] = I18n.t(:created_success, :model => Reminder.human_name, :scope => [:notice])
      redirect_to(:action => :list, :user => @user.login)
    else
      render :action => "new"
    end
  end

  # PUT /reminders/1
  # PUT /reminders/1.xml
  def update
    @reminder = Reminder.find(params[:id])

    if @reminder.update_attributes(params[:reminder])
      flash[:notice] = I18n.t(:updated_success, :model => Reminder.human_name, :scope => [:notice])
      redirect_to(:action => :list, :user => @user.login)
    else
      render :action => "edit"
    end
  end

  # DELETE /reminders/1
  # DELETE /reminders/1.xml
  def destroy
    @reminder = Reminder.find(params[:id])
    @reminder.destroy

    redirect_to(:action => :list, :user => @user.login)
  end

  def today
    @reminders = Reminder.todays(@user.id)
    list
  end

  def completed
    @reminders = Reminder.completeds(@user.id)
    list
  end

  def list
    @reminders ||=  @user.reminders
    @tags = tag_counts(@reminders)

    respond_to do |format|
      format.html { render :action => :index}
      format.js do
        render :update do |page|
          page['reminder'].reload 
        end
      end
      format.xml { render :action => :rss }
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
    tags = []
    tags << reminders.each{|r| tags += r.tag_counts }
    return tags.flatten.compact
  end
  
  def get_user_id(id)
    user_id = current_user.id unless id
    user_id ||= User.find(id).id
  end
end
