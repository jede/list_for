# ListFor
require "list_for/helper/link_renderer"
require "list_for/helper/support"

module ListFor
  module Helper
    include ListFor::Helper::Support
    
    def will_list_for(klass, options = {}, html_options = {}, &block)
      raise "will_list_for is deprecated! :("
      options = ListFor::Request.parse_params(options)

      list_settings = ListFor::Helper::ListSettings.new
      yield list_settings
    
      options[:use_filters] = !list_settings.methods.detect {|k,v| v[:filter] }.nil?
      
      options_for_will_paginate = {:page => options[:page], :per_page => options[:per_page]}
      [:total_entries, :count, :finder, :conditions, :order].each {|k| options_for_will_paginate << options.delete(k) if options.has_key?(k) }
      
      query = options.delete(:query)
      
      if options[:use_filters]
        conditions = klass.send(:sanitize_sql, options_for_will_paginate[:conditions]).to_s
        conditions = "(#{conditions})" unless conditions.empty?
        conditions = [conditions]
        
        list_settings.methods.each do |method, settings|
          # Do the filtering!
          accessor = ListFor::Helper::ListSettings.list_method_to_accessor(method)
          column = klass.columns.detect{|c| c.name == accessor}
          next if column.nil?
          
          unless options[:filters][accessor].blank?
            exact = 
             if not settings[:filter].is_a? Hash
               false
             elsif settings[:filter].has_key? :exact
               settings[:filter][:exact] && true
             elsif settings[:filter][:choices].is_a?(Array)
               true
             end
            
            options[:filters][accessor]
            
            if exact
              conditions << klass.send(:sanitize_sql, {accessor => value})
            else
              conditions << "#{klass.quoted_table_name}.#{klass.connection.quote_column_name(attr)} LIKE #{klass.quote(value, column)}"
            end
          end
        end
        
        conditions.join(" OR ")
        options_for_will_paginate[:conditions] = conditions
      end
      
      if options[:sort_accessor] && sort_column = klass.columns.detect{|c| c.name == options[:sort_accessor]}
        order = options[:sort_reverse] ? "DESC" : "ASC"
        options_for_will_paginate[:order] = klass.connection.quote_column_name(sort_column.name) + " #{order}"
      end
      
      collection = 
        if query.blank?
          klass.paginate(options_for_will_paginate)
        else
          klass.paginate_search(query, options_for_will_paginate)
        end
      
      choose_renderer(options[:format]).new(collection, list_settings, self, options).render(&block)
      
    end
    
    def list_for(collection, options = {}, html_options = {}, &block)
      options = ListFor::Request.parse_params(options)
      
      list_settings = ListFor::Helper::ListSettings.new
      yield list_settings
      
      options[:sort_accessor] = list_settings.list_method_to_accessor(options[:sort])
      options[:use_filters] = !list_settings.methods.detect {|k,v| v[:filter] }.nil?
      
      unless is_will_paginate_compatible?(collection)
        if options[:use_filters]
          list_settings.methods.each do |method, settings|
            # Do the filtering!
            accessor = list_settings.list_method_to_accessor(method)
            unless options[:filters][accessor].blank?
              exact = 
               if not settings[:filter].is_a? Hash
                 false
               elsif settings[:filter].has_key? :exact
                 settings[:filter][:exact] && true
               elsif settings[:filter][:choices].is_a?(Array)
                 true
               end
        
              collection = collection.select do |item|
                eval = eval("item.#{accessor}.to_s")
                if exact
                  eval == options[:filters][accessor]
                else
                  keep = true
                  eval = eval.downcase if eval.methods.include? "downcase"
                  keep = eval.include?(options[:filters][accessor].downcase) if eval.methods.include? "include?"
                end
              end
            end
          end
        end
        
        if !options[:sort_accessor].blank? && list_settings.uses_accessor?(options[:sort_accessor])
          order = options[:sort_reverse] ? -1 : 1
          collection.sort!{ |a,b| (eval("a.#{options[:sort_accessor]}") <=> eval("b.#{options[:sort_accessor]}") || -1)*order }
        end
      end
      
      choose_renderer(options[:format]).new(collection, list_settings, self, options).render(&block)
    end

    protected
    
    def choose_renderer(format)
      case format
      when :csv, :Csv
        Formats::Csv::Renderer
      when :xls, :excel
        Formats::Xls::Renderer
      else
        Formats::Html::Renderer
      end
    end
    
  end
end