# -*- coding: utf-8 -*-
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  ::WillPaginate::ViewHelpers.pagination_options[:prev_label] = I18n.t(:prev_label, :scope => :paginate)
  ::WillPaginate::ViewHelpers.pagination_options[:next_label] = I18n.t(:next_label, :scope => :paginate)
  
  def action_path(action, options={})
    return {:user => (params["user"] || @user.login), :controller => :reminders, :action => action, :tag => nil}.merge(options)
  end

  def logged_in?
    session[:user_id]
  end

  def current_user?
    logged_in? && session[:user_id].login == params["user"]
  end

  def current_user
    return session[:user_id]
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
  var pageTracker = _gat._getTracker("#{t(s)}");
  pageTracker._trackPageview();
</script>
EOS
  end
end
