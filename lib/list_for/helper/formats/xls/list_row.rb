require "spreadsheet/excel"

module ListFor
  module Helper
    module Formats
      module Xls
        class ListRow  < ListFor::Helper::ListRowBase
          def initialize(object, filters, list_settings)
            @object = object
            @list_settings = list_settings
            @object = object
            @values = []
          end

          def column(method, options = {}, &block)
            accessor = @list_settings.list_method_to_accessor(method)
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
