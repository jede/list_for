module ListFor
  module Helper
    module Formats
      module Csv
        class Renderer < ListFor::Helper::Formats::RendererBase
          def render(&block)
            @binding = block.binding
            title_row = []
            @list_settings.methods.each {|method, settings| title_row << settings[:alias] }
            concat title_row.to_csv + "\n"
            
            @collection.each do |item|
              row = ListRow.new(item, @options[:filters])
              yield row
              concat row.values.to_csv + "\n"
            end
          end
        end
      end
    end
  end
end