class TimelinesController < ApplicationController
  before_filter :save_current_list, :only => %w(today completed list)

  before_filter :add_crumb_list_action, :only => %w(show confirm_update confirm_create edit new create update)
  before_filter :add_crumb_show_action, :only => %w(confirm_update confirm_create edit create update)
  before_filter :add_crumb_current_action_with_tag, :only => %w(list today completed index)
  before_filter :add_crumb_current_action, :except => %w(list today completed index)
  
  def index
    redirect_to(:action => :today)
  end

  def show
    @reminder = Reminder.find(params[:id])
    render :action => :show
  end
  
  def today
    @reminders = Reminder.todays(:tag => params["tag"]).paginate(:page => params[:page])
    list
  end

  def list
    @reminders ||=  Reminder.lists(:tag => params["tag"]).paginate(:page => params[:page])
    logger.debug "DEBUG(list) : @reminders = <#{@reminders.to_yaml}>"
    @tags = tag_counts(@reminders)

    respond_to do |format|
      format.html { render :action => :index }
      format.rss { render :action => :rss }
    end
  end

  private
  def save_current_list
    session[:list_referer] = {
      :controller => controller_name,
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
end
