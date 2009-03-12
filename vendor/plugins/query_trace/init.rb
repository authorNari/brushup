if Rails.env == 'development'
  require 'query_trace'

  class ::ActiveRecord::ConnectionAdapters::AbstractAdapter
    include QueryTrace
  end
end
