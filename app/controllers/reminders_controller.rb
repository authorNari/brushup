class RemindersController < ApplicationController
  before_filter :login_required, :only => %w(new create destroy edit update check copy)
  before_filter :same_login_user_required, :only => %w(create destroy edit update check)
  before_filter :save_current_list, :only => %w(today completed list search)

  auto_complete_for :tag, :name

  before_filter :add_crumb_list_action, :only => %w(show confirm_update confirm_create edit new create update)
  before_filter :add_crumb_show_action, :only => %w(confirm_update edit create update)
  before_filter :add_crumb_create_action, :only => %w(confirm_create)
  before_filter :add_crumb_update_action, :only => %w(confirm_update)
  before_filter :add_crumb_current_action_with_tag, :only => %w(list today completed index search)
  before_filter :add_crumb_current_action, :except => %w(list today completed index search)

  helper_method :reminder_user
  
  def index
    redirect_to(:action => :today, :user => (params["user"] || reminder_user.login))
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
    @reminder = Reminder.new(params[:reminder].merge!(:user_id => current_user.id))

    if @reminder.valid?
      @reminder.save_with_update_user!
    
      return render(:template => "/share/autoclose") if @template.bookmarklet_window?
      flash[:notice] = I18n.t(:created_success, :model => Reminder.human_name, :scope => [:notice])
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
      
      flash[:notice] = I18n.t(:updated_success, :model => Reminder.human_name, :scope => [:notice])
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

    redirect_to(@template.back_list_path)
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
    logger.debug{ "DEBUG(list) : @reminders = <#{@reminders.to_yaml}>" }
    @tags = Reminder.tag_counts(:conditions => ["reminders.id IN (?)", @reminders.map(&:id)])
    @reminders = @reminders.paginate(:page => params[:page])

    respond_to do |format|
      format.html { render :action => :index }
      format.rss { render :action => :rss }
    end
  end

  def copy
    reminder = Reminder.find(params[:id])
    if reminder.deep_clone(current_user).save
      flash[:notice] = I18n.t(:copyed_success, :model => Reminder.human_name, :scope => :notice)
    else
      flash[:error] = I18n.t(:copyed_fail, :model => Reminder.human_name, :scope => :error)
      logger.debug "DEBUG(create): @reminder = <#{@reminder.to_yaml}>"
    end
    redirect_to :user => current_user.login, :action => :list
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
            page.replace_html "tag_today", @template.today_tag_label_link
            page.visual_effect :highlight, "reminder_#{params[:id]}"
            page.visual_effect :fade, "reminder_#{params[:id]}"
          end
        end
      end
    end
  end

  def auto_complete_for_tag_name
    @items = reminder_user.reminders.inject([]) do |r, rm|
      rm.tags.each{|t| r << t if /\A#{params[:tag][:name].downcase}/ =~ t.name }
      r
    end

    render :inline => "<%= auto_complete_result @items, 'name' %>"
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
