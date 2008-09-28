module ListFor
  module Helper
    module Formats
      module Html
        class ListRowURL < ListFor::Helper::ListRowBase
          def initialize(object, filters)
            @object = object
            @url_given = false
          end

          def url(&block)
            @url_given = true
            @url = yield @object
            nil
          end
          
          def called_url?
            @url_given
          end
          
          def url_for_row
            @url
          end
        end
      end
    end
  end
end
