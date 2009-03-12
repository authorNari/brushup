if %w(development test).include?(RAILS_ENV)
  require_dependency "safe_record"

  ActiveRecord::ConnectionAdapters.constants.each do |name|
    if /Adapter\z/.match(name) && /Abstract|Deprecated|SQLite[23]/ !~ name
      ActiveRecord::ConnectionAdapters.const_get(name).class_eval do
        include ActiveRecord::ConnectionAdapters::SafeRecord
      end
    end
  end
end
