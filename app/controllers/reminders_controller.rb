class RemindersController < ApplicationController
  before_filter :set_user
  before_filter :authorize, :only => %w(new create destroy edit update check)
  before_filter :set_jumpto
  before_filter :save_current_list, :only => %w(today completed list)

  auto_complete_for :tag, :name

  before_filter :add_crumb_list_action, :only => %w(show confirm_update confirm_create edit new create update)
  before_filter :add_crumb_show_action, :only => %w(confirm_update confirm_create edit create update)
  before_filter :add_crumb_create_action, :only => %w(confirm_create)
  before_filter :add_crumb_update_action, :only => %w(confirm_update)
  before_filter :add_crumb_current_action
  
  def index
    redirect_to(:action => :today, :user => (params["user"] || @user.login))
  end

  def show
    @reminder = Reminder.find(params[:id])
    render :action => :show
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
    @reminder = Reminder.new(params[:reminder].merge!(:user_id => @user.id))

    if @reminder.save
      flash[:notice] = I18n.t(:created_success, :model => Reminder.human_name, :scope => [:notice])
      return render(:template => "/share/autoclose") if @template.confirm_mode?
      redirect_to(:action => :confirm_create, :id => @reminder.id, :user => @user.login)
    else
      logger.debug "DEBUG(create): @reminder = <#{@reminder.to_yaml}>"
      render(:user => @user.login, :action => "new")
    end
  end

  def update
    @reminder = Reminder.find(params[:id])

    if @reminder.update_attributes(params[:reminder])
      flash[:notice] = I18n.t(:updated_success, :model => Reminder.human_name, :scope => [:notice])
      redirect_to(:action => :confirm_update, :id => @reminder.id, :user => @user.login)
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
    @show_reminder_detail = true
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
      @show_reminder_detail = true
      respond_to do |format|
        format.html { index }
        format.js do
          render :update do |page|
            page.replace "reminder_#{params[:id]}", (render :partial => "reminder", :locals => {:reminder => reminder})
            page.replace "reminders_check_#{params[:id]}", t(:check_ok, :scope => [:controller, :reminders])
            page.visual_effect :highlight, "reminder_#{params[:id]}"
            page.visual_effect :fade, "reminder_#{params[:id]}"
          end
        end
      end
    end
  end

  def auto_complete_for_tag_name
    @items = @user.reminders.inject([]) do |r, rm|
      rm.tags.each{|t| r << t if /\A#{params[:tag][:name].downcase}/ =~ t.name }
      r
    end

    render :inline => "<%= auto_complete_result @items, 'name' %>"
  end

  private
  def save_current_list
    session[:list_referer] = {
      :user => params[:user],
      :action => params[:action],
      :id => params[:id],
      :tag => params[:tag],
    }
  end
  
  def tag_counts(reminders)
    tags = {}
    reminders.each{|r| r.tag_counts.each{|t| tags[t.name] ||= []; tags[t.name] << t }}
    return tags.values
  end

  def add_crumb_show_action
    add_crumb(t("show", :scope => [:controller, controller_name]), @template.action_path(:show, :id => params[:id]))
  end

  def add_crumb_list_action
    
    add_crumb(t(@template.back_list_path[:action], :scope => [:controller, controller_name]), @template.back_list_path)
  end
  
  def add_crumb_create_action
    add_crumb(t("create", :scope => [:controller, controller_name]), @template.action_path(:new))
  end
  
  def add_crumb_update_action
    add_crumb(t("update", :scope => [:controller, controller_name]), @template.action_path(:edit, :id => params[:id]))
  end
end
