require "spreadsheet/excel"

module ListFor
  module Helper
    module Formats
      module Xls
        class Renderer < ListFor::Helper::Formats::RendererBase
          def file_provided?
            @list_settings[:file].is_a? IO
          end
          
          def render(&block)
            @file =  file_provided? ? @list_settings[:file] : TempFile.new
            @workbook = Excel.new(@file)
            @worksheet = @workbook.add_worksheet
            
            header_format = Format.new
            header_format.bold = true
            
            #title row
            @worksheet.write 0,0, @list_settings.methods.collect {|method, settings| settings[:alias] }, header_format
                        
            @collection.each_with_index do |item, r|
              row = ListRow.new(item, @options[:filters])
              yield row
              @worksheet.write row,0, row.values
            end
            
            if file_provided?
              @file
            else
              @file.read_contents
            end
          end
        end
      end
    end
  end
end