# Rails 2.0 dependent code

if defined? ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
  module ActiveRecord
    module ConnectionAdapters
      class PostgreSQLAdapter
        def client_min_messages_with_quote=(level)
          execute("SET client_min_messages TO #{quote(level)}")
        end
        alias_method_chain(:client_min_messages=, :quote)

        def last_insert_id_with_quote(table, sequence_name)
          Integer(select_value("SELECT currval(#{quote(sequence_name)})"))
        end
        alias_method_chain(:last_insert_id, :quote)
      end
    end
  end
end
