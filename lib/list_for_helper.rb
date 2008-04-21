# ListFor
module ListForHelper
  class ListSettings
    def initialize
      @actions = false
      @methods = ActiveSupport::OrderedHash.new
    end
    
    def column(method, options = {}, &block)
      options[:alias] = (method.is_a?(Array) ? method.first : method).to_s.humanize unless options[:alias]
      @methods[method] = options
      nil
    end
    
    def actions(&block)
      @actions = true
      nil
    end

    def actions?
      @actions
    end
    
    def aliases
      @methods.values
    end
    
    def methods
      @methods
    end
    
    def accessors
      @methods.keys.collect{|m| ListForHelper::ListRow.list_method_to_accessor(m)}
    end
    
    def uses_accessor?(accessor)
      accessors.include?(accessor)
    end
    
  end
  
  class ListRow
    def initialize(object, filters)
      @object = object
      @filters = filters.is_a?(Hash) ? filters : {}
    end
    
    def column(method, method_alias = nil, &block)
      if block_given?
        eval 'concat "<td>", binding', block.binding
        yield @object
        eval 'concat "</td>", binding', block.binding
      else        
        accessor = ListForHelper::ListRow.list_method_to_accessor(method)
        value = eval("@object.#{accessor}.to_s")
        value = value.gsub(Regexp.new("(#{@filters[accessor]})", "i"), '<span class="highlight">\1</span>') unless @filters[accessor].blank?
        '<td>'+value+'</td>'
      end
    end
    
    def actions(&block)
      eval 'concat "<td>", binding', block.binding
      yield @object if block_given?
      eval 'concat "</td>", binding', block.binding
    end
    
    def self.list_method_to_accessor(method)
      if method.is_a? Array
        method.collect{|m| m.to_s}.join('.')
      else
        method.to_s
      end
    end
  end
  
  class LinkRenderer < Kernel::WillPaginate::LinkRenderer
    def url_options(page)
      if param_name.to_s.include?('[')
        options = page
        param_name.to_s.gsub(']', '').split('[').reverse.each do |key|
          options = {key.to_sym => options}
        end
      else
        options = {param_name => page}
      end
      # page links should preserve GET parameters
      options = params.merge(options) if @template.request.get?
      options.rec_merge!(@options[:params]) if @options[:params]
      return options
    end
  end
  
  def make_paginate_object(array_object, page, per_page)
    return array_object if array_object.is_a? WillPaginate::Collection
    
    size = array_object.size
    entries = WillPaginate::Collection.create(page, per_page, size) do |pager|
      if (page - 1) * per_page > size
        start_pos = size - per_page
        start_pos = 0 if start_pos < 0
        end_pos = size
      else
        start_pos = (page - 1) * per_page
        end_pos = start_pos + per_page
        end_pos = size if end_pos > size
      end
      result = array_object[start_pos...end_pos]
      pager.replace(result)
    end    
  end

  def list_for(collection, options = {}, html_options = {}, &block)
    @list_for ||= {}
    options[:name] = options[:name].blank? ? "default" : options[:name].to_s
    options = options.merge(@list_for[options[:name].to_sym] || {})
    options[:filters] ||= {}

    page = (options[:page] || 1).to_i
    per_page = (options[:per_page] || 20).to_i
    prefix = "list_for" + (options[:name].blank? ? "" : "[" + options[:name] + "]")
    
    list_settings = ListForHelper::ListSettings.new
    yield list_settings
    
    sort_accessor = ListForHelper::ListRow.list_method_to_accessor(options[:sort])
    sort_reverse = options[:reverse] == "1" || options[:reverse] === true
    uri = URI.parse(options[:url].is_a?(Hash) ? url_for(options[:url]) : (options[:url] || url_for))

    if (list_settings.methods.select {|k,v| v[:filter] }.length > 0)

    concat('<div class="filters">', block.binding)
    concat('<form method="GET" action="'+uri.to_s+'">', block.binding)
    search_button = false
    list_settings.methods.each do |method, settings|
      if settings[:filter]
        search_button = true
        settings[:filter] = {} unless settings[:filter].is_a?(Hash)
        # Print out the filter field
        accessor = ListForHelper::ListRow.list_method_to_accessor(method)
        name = prefix+'[filters]['+accessor+']'
        value = options[:filters][accessor].to_s
        concat('<div class="filter"><label>'+settings[:alias]+':</label> ', block.binding)
        if settings[:filter][:choices].is_a?(Array)
          concat(select_tag(name, options_for_select([''] + settings[:filter][:choices], value)), block.binding)
        else
          concat(text_field_tag(name, value), block.binding)
        end
        concat('</div>', block.binding)
        
        # Do the filtering!
        if options[:filters].is_a?(Hash) && !options[:filters][accessor].blank?
          exact = false
          if settings[:filter][:exact] === true || settings[:filter][:exact] === false
            exact = settings[:filter][:exact]
          elsif settings[:filter][:choices].is_a?(Array)
            exact = true
          end
          
          collection = collection.select do |item|
            eval = eval("item.#{accessor}")
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
    concat('<input type="submit" value="Search"/>', block.binding) if search_button
    concat('</form></div>', block.binding)
    
    concat('<div style="clear:both"></div>', block.binding)
    
    end
    
    #Title row
    concat('<table class="list" cellspacing="0" cellpadding="0">', block.binding)
    concat('<tr">', block.binding)
    list_settings.methods.each do |method, settings|
      heading = settings[:alias]
      accessor = ListForHelper::ListRow.list_method_to_accessor(method)
      icon = accessor == sort_accessor ? image_tag((sort_reverse ? "down" : "up")+".png", :class => "icon") : ""
      uri_copy = add_to_uri(uri, {prefix+"[sort]" => accessor, prefix+"[page]" => page.to_s, prefix+"[reverse]" => ((!sort_reverse && accessor == sort_accessor) ? "1" : "0")})
      concat("<th><a href=\"#{uri_copy.to_s}\">#{heading} #{icon}</a></th>", block.binding)
    end
    concat("<th>&nbsp;</th>", block.binding) if list_settings.actions?
    concat('</tr>', block.binding)
    
    if sort_accessor && list_settings.uses_accessor?(sort_accessor)
      order = sort_reverse ? -1 : 1
      collection.sort!{ |a,b| (eval("a.#{sort_accessor}") <=> eval("b.#{sort_accessor}") || -1)*order }
    end
    
    collection = make_paginate_object(collection, page, per_page)

    collection.each do |item|
      concat('<tr class="'+cycle('even', 'odd', :name => prefix)+'">', block.binding)
      yield ListForHelper::ListRow.new(item, options[:filters])
      concat('</tr>', block.binding)
    end
    
    concat('</table>', block.binding)
    
    concat(will_paginate(collection, 
      :param_name => prefix+"[page]", 
      :params => {
        prefix+"[sort]" => options[:sort], 
        prefix+"[reverse]" => options[:reverse],
        prefix+"[filters]" => options[:filters]}, 
      :renderer => ListForHelper::LinkRenderer).to_s, block.binding)
  end
  
  protected
  
  def add_to_uri(uri, params)
    uri_copy = uri.clone
    uri_copy.query.to_s.split('&').each do |p| 
      params[p.split('=')[0]] ||= p.split('=')[1].to_s
    end
    uri_copy.query = params.to_a.collect{|pair| pair[0].to_s+"="+pair[1].to_s}.join('&')
    uri_copy
  end
end