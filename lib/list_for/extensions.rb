module ListFor
  module Extensions
    # def self.included(base)
    #   base.extend(ClassMethods)
    # end
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
  end
end