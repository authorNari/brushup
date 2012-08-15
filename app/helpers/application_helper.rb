# -*- coding: utf-8 -*-
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  ::WillPaginate::ViewHelpers.pagination_options[:prev_label] = I18n.t(:prev_label, :scope => :paginate)
  ::WillPaginate::ViewHelpers.pagination_options[:next_label] = I18n.t(:next_label, :scope => :paginate)
  
  def action_path(action, options={})
    return {:user => (params["user"] || current_user.login), :controller => :reminders, :action => action, :tag => nil}.merge(options)
  end

  def display_date(date)
    return date.strftime("%Y年%m月%d日")
  end

  # Google Analyticsのためのコードを取得する。
  def google_analytics
    s = Configuration.instance.google_analytics
    if s.empty?
      return ""
    end
    return <<EOS
<script type="text/javascript">
  var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
  document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
  var pageTracker = _gat._getTracker("#{h(s)}");
  pageTracker._trackPageview();
</script>
EOS
  end

  # Google Adsenseのためのコードを取得する。
  def google_adsense
    s = Configuration.instance.google_adsense
    if s.empty?
      return ""
    end
    return <<EOS
<script type="text/javascript"><!--
google_ad_client = "#{h(s)}";
google_ad_slot = "0051653286";
google_ad_width = 200;
google_ad_height = 200;
//-->
</script>
<script type="text/javascript" src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
EOS
  end


  def rss_reminder_pubDate(reminder)
    return reminder.updated_at.to_formatted_s(:rfc822) if params[:action] == "today"
    return reminder.created_at.gmtime.to_formatted_s(:rfc822)
  end

  def rss_reminder_title(reminder)
    title = reminder.title
    return "#{title} (#{t(:to_complete_count, :scope => :text, :count => reminder.to_complete_count)})" if params[:action] == "today"
    return title
  end
  
  def rss_reminder_link(reminder)
    if params[:action] == "today"
      url_for(action_path(:show, :id => reminder.id, :brushup_date => reminder.next_learn_date, :only_path => false))
    else
      url_for(action_path(:show, :id => reminder.id, :only_path => false))
    end
  end
  
  def tag_cloud_styles
    return %w(tag-light tag-normal tag-many tag-very-many)
  end

  def title_tag_prefix(tag=nil)
    tag = params["tag"] || tag
    return h("/ #{tag}(#{@reminders.size})") if tag
  end
  
  def hidden_reminder_detail
    if not @show_reminder_detail == true
      return "style='display:none;'"
    end
  end
  
  def current_tag(action_name)
    return "current-menu"  if params["action"] == action_name
  end

  def bookmarklet_window?
    params[:mode] == "confirm"
  end

  def copiable_reminder?(reminder)
    logged_in? && reminder.user.login != current_user.login
  end
  
  def back_list_path
    if session[:list_referer] && session[:list_referer][:controller] == controller_name
      return session[:list_referer]
    end
    return action_path(:index)
  end

  def reminder_delay_date_count(reminder)
    cnt = Date.today - reminder.next_learn_date
    return "(#{t(:reminder_delay, :scope => :text, :count => h(cnt))})" if cnt > 5
    ""
  end

  def link_to_menu(show_actions, label, link)
    if show_actions == :all
      return link_to_unless(link[:controller].to_s == controller_name, label, link)
    end
    link_to_unless(((link[:controller].to_s == controller_name) &&
                    show_actions.map(&:to_s).include?(params[:action])),
                   label, link)
  end

  def today_reminder_notice_link
    if logged_in?
      link_to(flash[:reminder_notice], action_path(:today, :user => current_user.login, :controller => :reminders))
    end
  end

  def rss_link
    rss_link = params.dup
    rss_link.delete(:format)
    url_for(rss_link.merge(:only_path => false))
  end
end
