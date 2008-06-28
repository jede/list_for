# ListFor
require "list_for/helper/link_renderer"

module ListFor
  module Helper

    def list_for(collection, options = {}, html_options = {}, &block)
      @list_for ||= {}
      options[:name] = 
      if !options[:name].blank?
        options[:name].to_s
      elsif first = collection.first
        first.class.to_s.underscore
      else
        'default'
      end
      options = options.merge(@list_for[options[:name].to_sym] || {})
      options[:filters] ||= {}

      options[:page] = (options[:page] || 1).to_i
      options[:per_page] = (options[:per_page] || 20).to_i
      #prefix = "list_for" + (options[:name].blank? ? "" : "[" + options[:name] + "]")
    
      list_settings = ListFor::Helper::ListSettings.new
      yield list_settings
    
      options[:sort_accessor] = ListFor::Helper::ListSettings.list_method_to_accessor(options[:sort])
      options[:sort_reverse] = options[:reverse] == "1" || options[:reverse] === true
      options[:uri] = URI.parse(options[:url].is_a?(Hash) ? url_for(options[:url]) : (options[:url] || url_for))
    
      options[:use_filters] = !list_settings.methods.detect {|k,v| v[:filter] }.nil?
      options[:filters] = options[:filters] || {}
    
      if options[:use_filters]
        list_settings.methods.each do |method, settings|
          # Do the filtering!
          accessor = ListFor::Helper::ListSettings.list_method_to_accessor(method)
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
    
      if options[:sort_accessor] && list_settings.uses_accessor?(options[:sort_accessor])
        order = options[:sort_reverse] ? -1 : 1
        collection.sort!{ |a,b| (eval("a.#{options[:sort_accessor]}") <=> eval("b.#{options[:sort_accessor]}") || -1)*order }
      end
      
      render_class = 
        case options[:format]
        when :csv, :CSV
          Formats::CSV::Renderer
        else
          Formats::HTML::Renderer
        end
      
      render_class.new(collection, list_settings, self, options).render(&block)
    end
    
  end
end