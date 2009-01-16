module ListFor
  class Request
    cattr_accessor :controller, :params, :initiated
    
    def self.init(controller, params)
      Request.initiated = true
      Request.controller = controller
      Request.params = params || {}
    end
    
    def self.parse_params(options)
      return options unless initiated
      
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

      options[:sort_reverse] = options[:reverse] == "1" || options[:reverse] === true
      options[:filters] = options[:filters] || {}
      uri_params = 
        if options[:url].is_a?(Hash) || options[:url].is_a?(String)
          controller.url_for(options[:url])
        elsif params[:url].is_a?(String)
          params[:url]
        else
          (options[:url] || controller.url_for)
        end
      options[:uri] = URI.parse(uri_params)
      options
    end    
  end
end