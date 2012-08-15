# -*- coding: utf-8 -*-
module ActsAsTaggableOn::Taggable
  module Collection
    module ClassMethods
      # scope[:conditions]が反映されず、タグの絞り込みができない
      def all_tag_counts(options = {})
        options.assert_valid_keys :start_at, :end_at, :conditions, :at_least, :at_most, :order, :limit, :on, :id, :tagging_conditions

        scope = {}

        ## Generate conditions:
        options[:conditions] = sanitize_sql(options[:conditions]) if options[:conditions]
        scope[:conditions] = options[:tagging_conditions] if options[:tagging_conditions]

        start_at_conditions = sanitize_sql(["#{ActsAsTaggableOn::Tagging.table_name}.created_at >= ?", options.delete(:start_at)]) if options[:start_at]
        end_at_conditions   = sanitize_sql(["#{ActsAsTaggableOn::Tagging.table_name}.created_at <= ?", options.delete(:end_at)])   if options[:end_at]
        
        taggable_conditions  = sanitize_sql(["#{ActsAsTaggableOn::Tagging.table_name}.taggable_type = ?", base_class.name])
        taggable_conditions << sanitize_sql([" AND #{ActsAsTaggableOn::Tagging.table_name}.taggable_id = ?", options.delete(:id)])  if options[:id]
        taggable_conditions << sanitize_sql([" AND #{ActsAsTaggableOn::Tagging.table_name}.context = ?", options.delete(:on).to_s]) if options[:on]
        
        tagging_conditions = [
          taggable_conditions,
          scope[:conditions],
          start_at_conditions,
          end_at_conditions
        ].compact.reverse
        
        tag_conditions = [
          options[:conditions]        
        ].compact.reverse
        
        ## Generate joins:
        taggable_join = "INNER JOIN #{table_name} ON #{table_name}.#{primary_key} = #{ActsAsTaggableOn::Tagging.table_name}.taggable_id"
        taggable_join << " AND #{table_name}.#{inheritance_column} = '#{name}'" unless descends_from_active_record? # Current model is STI descendant, so add type checking to the join condition      

        tagging_joins = [
          taggable_join,
          scope[:joins]
        ].compact

        tag_joins = [
        ].compact

        ## Generate scope:
        tagging_scope = ActsAsTaggableOn::Tagging.select("#{ActsAsTaggableOn::Tagging.table_name}.tag_id, COUNT(#{ActsAsTaggableOn::Tagging.table_name}.tag_id) AS tags_count")
        tag_scope = ActsAsTaggableOn::Tag.select("#{ActsAsTaggableOn::Tag.table_name}.*, #{ActsAsTaggableOn::Tagging.table_name}.tags_count AS count").order(options[:order]).limit(options[:limit])   

        # Joins and conditions
        tagging_joins.each      { |join|      tagging_scope = tagging_scope.joins(join)      }        
        tagging_conditions.each { |condition| tagging_scope = tagging_scope.where(condition) }

        tag_joins.each          { |join|      tag_scope     = tag_scope.joins(join)          }
        tag_conditions.each     { |condition| tag_scope     = tag_scope.where(condition)     }

        # GROUP BY and HAVING clauses:
        at_least  = sanitize_sql(['tags_count >= ?', options.delete(:at_least)]) if options[:at_least]
        at_most   = sanitize_sql(['tags_count <= ?', options.delete(:at_most)]) if options[:at_most]
        having    = ["COUNT(#{ActsAsTaggableOn::Tagging.table_name}.tag_id) > 0", at_least, at_most].compact.join(' AND ')    

        group_columns = "#{ActsAsTaggableOn::Tagging.table_name}.tag_id"

        # Append the current scope to the scope, because we can't use scope(:find) in RoR 3.0 anymore:
        scoped_select = "#{table_name}.#{primary_key}"
        tagging_scope = tagging_scope.where("#{ActsAsTaggableOn::Tagging.table_name}.taggable_id IN(#{select(scoped_select).to_sql})").
                                      group(group_columns).
                                      having(having)


        tag_scope = tag_scope.joins("JOIN (#{tagging_scope.to_sql}) AS #{ActsAsTaggableOn::Tagging.table_name} ON #{ActsAsTaggableOn::Tagging.table_name}.tag_id = #{ActsAsTaggableOn::Tag.table_name}.id")
        tag_scope
      end
    end
  end
end
