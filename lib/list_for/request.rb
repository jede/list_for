module ListFor
  class Request
    cattr_accessor :params
    
    def self.parse_params(options)
      Request.params ||= {}
      options[:name] = 
      if !options[:name].blank?
        options[:name].to_s
      else
        'default'
      end
      options = options.merge(Request.params[options[:name].to_sym] || {})
      options[:filters] ||= {}

      options[:page] = (options[:page] || 1).to_i
      options[:per_page] = (options[:per_page] || 20).to_i

      options[:sort_accessor] = ListFor::Helper::ListSettings.list_method_to_accessor(options[:sort])
      options[:sort_reverse] = options[:reverse] == "1" || options[:reverse] === true
      options[:filters] = options[:filters] || {}
      options
    end
  end
end