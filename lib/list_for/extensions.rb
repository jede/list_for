module ListFor
  module Extensions
    
    module ActiveRecord
      module Base
        module ClassMethods
          
          def paginate_search(query, options = {})
            page, per_page, total = wp_parse_options(options)
            pager = WillPaginate::Collection.new(page, per_page, total)
            options.merge!(:offset => pager.offset, :limit => per_page)
            result = find_by_contents(query, options)
            returning WillPaginate::Collection.new(page, per_page, result.total_hits) do |pager|
              pager.replace result
            end
          end
        end
      end
    end
    
    module ActionController
      module InstanceMethods
        def load_list_params
          @list_for ||= {}
          @list_for[:url] = request.env['REQUEST_URI']
          (params[:list_for] || {}).each do |key, param|
            if param.is_a? Hash
              @list_for[key.to_sym] = {}
              @list_for[key.to_sym][:url] = request.env['REQUEST_URI']
              [:sort, :page, :reverse, :filters].each do |fetch|
                @list_for[key.to_sym][fetch] = param[fetch] if param[fetch]
              end
            end
          end
          ListFor::Request.init(self, @list_for)
        end
      end
    end
    
    module Array
      module InstanceMethods
        def to_csv
          collect { |value| '"'+value.gsub('"', '""')+'"' }.join(',')
        end
      end
    end
    
    module TrueClass
      module InstanceMethods
        def <=>(arg)
          if self == arg
            0
          else
            -1
          end
        end
      end
    end

    module FalseClass
      module InstanceMethods
        def <=>(arg)
          if self == arg
            0
          else
            1
          end
        end
      end
    end

    module NilClass
      module InstanceMethods
        def <=>(arg)
          if self == arg
            0
          else
            1
          end
        end
      end
    end
  
    module ThinkingSphinx
      module ActiveRecord
        def self.included(base)
          base.class_eval do
            class << self
              def search_with_list_for(*args)
                options = args.extract_options!
                params = ListFor::Request.parse_params(options[:list_for] || {})
                options[:page] ||= params[:page]
                options[:per_page] ||= params[:per_page]
                unless params[:sort].blank?
                  options[:order] ||= params[:sort].to_sym
                  options[:sort_mode] ||= params[:sort_reverse] ? :desc : :asc
                end
                
                args << options
                search_without_list_for(*args)
              end
              alias_method_chain :search, :list_for
              
            end
          end
        end
      end
    end
  
  end
end