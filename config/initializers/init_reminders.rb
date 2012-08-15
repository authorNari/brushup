# -*- coding: utf-8 -*-
begin
  # returningを利用しているライブラリの互換性のため
  def returning(value)
    yield(value)
    value
  end

  require 'fixed_sting_to_xs'
  require 'fixed_all_tag_counts'
  require 'restful-authentication/init'
  require 'authenticated_system'
  require 'brushup'
  require 'open_id_authentication_to_i18n'
  require 'redcloth3'
  require 'authenticated_test_helper'
  require 'friendly_id'
  $: << File.expand_path("../../lib/dynamic_form/lib/", File.dirname(__FILE__))
  require 'dynamic_form/init'
  
  ActsAsTaggableOn.delimiter = " "
  ActsAsTaggableOn.remove_unused_tags = true

  # bugfix
  # http://stackoverflow.com/questions/4725609/how-add-url-for-in-custom-method-in-ruby
  class Crummy::StandardRenderer
    include ActionView::Helpers
    include ActionDispatch::Routing
    include Rails.application.routes.url_helpers
  end

  OpenIdAuthentication.store = OpenID::Store::ActiveRecord.new

  # https://github.com/openid/ruby-openid/issues/1#commits-ref-aad1c5f
  module OpenID
    class Consumer
      class CheckIDRequest
        def redirect_url(realm, return_to=nil, immediate=false)
          message = get_message(realm, return_to, immediate)
          message.del_arg(OPENID_NS, 'assoc_handle') if @assoc
          return message.to_url(@endpoint.server_url)
        end
      end
    end
  end
  
rescue Exception => ex
  puts "\nBrushup initialization failure."
  puts "\nPlease check config/initializers/inflections.rb"
  puts "\nError Class:\n\n #{ex.class}"
  puts "\nError Messages:\n\n  #{ex.message}"
  puts "\nError Backtrace:\n\n  #{ex.backtrace.join("\n  ")}"
  exit(1)
end

