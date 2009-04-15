xml.instruct!
 
xml.rss("version"    => "2.0",
        "xmlns:dc"   => "http://purl.org/dc/elements/1.1/",
        "xmlns:atom" => "http://www.w3.org/2005/Atom") do
  xml.channel do
    xml.title rss_title
    xml.link rss_link
    xml.pubDate     Time.now.gmtime.rfc822
    xml.description t(params["action"], :scope => [:controller, controller_name])
    xml.atom :link, "href" => url_for(action_path(params["action"]).merge(:only_path => false)), "rel" => "self", "type" => "application/rss+xml"
    xml.language     "ja"
 
    @reminders.each do |r|
      xml.item do |item|
        xml.title        rss_reminder_title(r)
        xml.link         rss_reminder_link(r)
        xml.guid         rss_reminder_link(r)
        xml.description{|d| d.cdata!(r.body) }
        xml.pubDate      rss_reminder_pubDate(r)
        r.tag_list.each{|t| xml.category(t) }
        xml.dc :creator, r.user.login
      end
    end
  end
end
