require "spreadsheet/excel"

module ListFor
  module Helper
    module Formats
      module Xls
        class Renderer < ListFor::Helper::Formats::RendererBase
          def file_provided?
            @options[:file].is_a?(IO) || @options[:file].is_a?(Tempfile)
          end
          
          def render(&block)
            @file =  file_provided? ? @options[:file] : Tempfile.new(@options[:name])
            @workbook = Spreadsheet::Excel.new(@file)
            @worksheet = @workbook.add_worksheet(@options[:name])
            
            header_format = Spreadsheet::Format.new
            #header_format.bold = true
            
            row_index = 0
            #title row
            @worksheet.write row_index,0, @list_settings.methods.collect {|method, settings| settings[:alias] }, header_format
            
            @collection.each do |item|
              row = ListRow.new(item, @options[:filters], @list_settings)
              yield row
              @worksheet.write((row_index += 1), 0, row.values)
            end
            
            @workbook.close
            @file.open
            
            if file_provided?
              @file
            else
              @file.read
            end
          end
        end
      end
    end
  end
end