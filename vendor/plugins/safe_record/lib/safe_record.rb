# SafeRecord

module ActiveRecord
  module ConnectionAdapters
    module SafeRecord
      def self.included(adapter)
        adapter.class_eval do
          alias_method_chain(:quote, :safe_record)
          alias_method_chain(:quote_column_name, :safe_record)
          alias_method_chain(:execute, :safe_record)
        end
      end

      def quote_with_safe_record(value, column = nil)
        quote_without_safe_record(value, column).dup.untaint
      end

      def quote_column_name_with_safe_record(name)
        quote_column_name_without_safe_record(name).dup.untaint
      end

      def execute_with_safe_record(sql, name = nil)
        if sql.tainted? && !defined?(Rake) && RAILS_ENV != "test"
          raise SecurityError.new("tainted sql: " + sql)
        end
        execute_without_safe_record(sql, name)
      end
    end
  end
end

# Adhock patching
if Rails::VERSION::MAJOR >= 2
  require 'adhock/rails_2'
end
