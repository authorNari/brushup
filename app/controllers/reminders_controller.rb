class RemindersController < ApplicationController
  before_filter :authorize, :except => %w(index today completed show check)
  before_filter :set_user, :except => %w(check)
  before_filter :set_jumpto

  # GET /reminders
  # GET /reminders.xml
  def index
    p session[:user_id]
    @reminders ||=  @user.reminders

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
    @reminder = Reminder.new(params[:reminder])

    respond_to do |format|
      if @reminder.save
        flash[:notice] = I18n.t(:created_success, :default => '{{model}} was successfully created.', :model => Reminder.human_name, :scope => [:railties, :scaffold])
        format.html { redirect_to(@reminder) }
        format.xml  { render :xml => @reminder, :status => :created, :location => @reminder }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @reminder.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /reminders/1
  # PUT /reminders/1.xml
  def update
    @reminder = Reminder.find(params[:id])

    respond_to do |format|
      if @reminder.update_attributes(params[:reminder])
        flash[:notice] = I18n.t(:updated_success, :default => '{{model}} was successfully updated.', :model => Reminder.human_name, :scope => [:railties, :scaffold])
        format.html { redirect_to(@reminder) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @reminder.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /reminders/1
  # DELETE /reminders/1.xml
  def destroy
    @reminder = Reminder.find(params[:id])
    @reminder.destroy

    respond_to do |format|
      format.html { redirect_to(reminders_url) }
      format.xml  { head :ok }
    end
  end

  def today
    @reminders = Reminder.todays(@user.id)
    index
  end

  def completed
    @reminders = Reminder.completeds(@user.id)
    index
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
  def get_user_id(id)
    user_id = current_user.id unless id
    user_id ||= User.find(id).id
  end
end
