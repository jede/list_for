module ListFor
  module Helper
    module Formats
      module Html
        class ListRow < ListFor::Helper::ListRowBase
          def initialize(object, filters)
            @object = object
            @filters = filters.is_a?(Hash) ? filters : {}
          end

          def column(method, options = {}, &block)
            html_options = [:style, :class].inject("") do |html, attr| 
              val = options.delete(attr)
              html << %' #{attr.to_s}="#{val.to_s}"' if val
              html
            end

            if block_given?
              eval "concat '<td#{html_options}>', binding", block.binding
              yield @object
              eval "concat '</td>', binding", block.binding
            else        
              accessor = ListFor::Helper::ListSettings.list_method_to_accessor(method)
              value = eval("@object.#{accessor}.to_s")
              value = value.gsub(Regexp.new("(#{@filters[accessor]})", "i"), '<span class="highlight">\1</span>') unless @filters[accessor].blank?
              "<td#{html_options}>"+value+'</td>'
            end
          end

          def actions(label = nil, &block)
            eval 'concat "<td>", binding', block.binding
            yield @object if block_given?
            eval 'concat "</td>", binding', block.binding
          end
          
          def url(&block)
            @url = yield @object
            nil
          end
          
          def url_for_row
            @url
          end
        end
      end
    end
  end
end
