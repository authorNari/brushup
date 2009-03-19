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

  def brushup_text_field_with_auto_complete(field, method, tag_options, completion_options)
    returning "" do |html|
      unless completion_options[:skip_style]
        html << auto_complete_stylesheet
      end

      html << field.text_field(method, tag_options.update(:id => "tag_name"))
      html << content_tag("div", "", :id => "tag_name_auto_complete", :class => "auto_complete")
      html << auto_complete_field("tag_name", 
        {:url => {:action => "auto_complete_for_tag_name"}}.update(completion_options)
      )
    end
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
google_ad_slot = "5027540674";
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
  
  def tag_cloud(tags, classes)
    return if tags.empty?
    
    max_count = tags.sort_by(&:size).last.size.to_f
    
    tags.each do |tag|
      index = ((tag.size / max_count) * (classes.size - 1)).round
      yield tag.first, classes[index]
    end
  end
  
  def hidden_reminder_detail
    unless @show_reminder_detail
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

end
