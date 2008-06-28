module ListFor
  module Helper
    module Formats
      class RendererBase
        def initialize(collection, list_settings, template, options)
          @template = template
          @options = options
          @list_settings = list_settings
          @collection = collection
        end
        
        def render; end

        def concat(str)
          @template.concat str, @binding
        end

        protected

        protected

        def add_to_uri(uri, params)
          uri_copy = uri.clone
          query_hash = (defined?(CGIMethods) ? CGIMethods : ActionController::AbstractRequest).parse_query_parameters(uri_copy.query)
          uri_copy.query = symbolize_all_keys(query_hash).merge(symbolize_all_keys(params)).to_query
          uri_copy
        end

        def symbolize_all_keys(arg)
          return arg unless arg.is_a? Hash

          arg.inject({}) do |hash, (key, value)|
            hash[key.to_sym || key] = symbolize_all_keys(value)
            hash
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
      end
    end
  end
end