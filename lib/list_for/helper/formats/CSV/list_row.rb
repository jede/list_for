module ListFor
  module Helper
    module Formats
      module Csv
        class ListRow  < ListFor::Helper::ListRowBase
          def initialize(object, filters)
            @object = object
            @values = []
          end

          def column(method, options = {}, &block)
            accessor = ListFor::Helper::ListSettings.list_method_to_accessor(method)
            @values << eval("@object.#{accessor}.to_s")
            nil
          end
          
          def values
            @values
          end
        end
      end
    end
  end
end
