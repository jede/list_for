module ListFor
  module Helper
    class LinkRenderer < Kernel::WillPaginate::LinkRenderer
      def page_link_or_span(page, span_class, text = nil)
        text ||= page.to_s
        classnames = Array[*span_class]

        if page and page != current_page
          if @options[:update]
            uri = URI.parse(@template.url_for(@options[:url]))
            @url_params = {}
            # page links should preserve GET parameters
            stringified_merge @url_params, @template.params.except(:controller).except(:action) if @template.request.get?
            stringified_merge @url_params, @options[:params] if @options[:params]

            if param_name.index(/[^\w-]/)
              page_param = (defined?(CGIMethods) ? CGIMethods : ActionController::AbstractRequest).parse_query_parameters("#{param_name}=#{page}")

              stringified_merge @url_params, page_param
            else
              @url_params[param_name] = page
            end

            uri.query = @url_params.to_query

            @template.link_to_remote text, :url => uri.to_s, :rel => rel_value(page), :class => classnames[1], :update => @options[:update], :method => @options[:method]
          else
            @template.link_to text, url_for(page), :rel => rel_value(page), :class => classnames[1]
          end
        else
          @template.content_tag :span, text, :class => classnames.join(' ')
        end
      end

      # For compability with old versions of will_paginate
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
  end
end