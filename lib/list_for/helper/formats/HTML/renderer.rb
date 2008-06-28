module ListFor
  module Helper
    module Formats
      module HTML
        class Renderer < ListFor::Helper::Formats::RendererBase
          def render(&block)
            @binding = block.binding
            if @collection.size == 1
              row = ListRowURL.new(@collection.first, @options[:filters])
              yield row
              concat '<meta http-equiv="refresh" content="0;url='+@template.url_for(row.url_for_row)+'"/>' if row.called_url?
            end
            
            filters if @options[:use_filters]
            list(&block)
          end

          protected

          def filters
            concat '<div class="filters">'
            concat '<form method="GET" action="'+@options[:uri].to_s+'">'
            search_button = false
            @list_settings.methods.each do |method, settings|
              if settings[:filter]
                search_button = true
                settings[:filter] = {} unless settings[:filter].is_a?(Hash)
                # Print out the filter field
                accessor = ListFor::Helper::ListSettings.list_method_to_accessor(method)
                name = "list_for[#{@options[:name]}][filters][#{accessor}]"
                value = @options[:filters][accessor].to_s
                concat '<div class="filter"><label>'+settings[:alias]+':</label> '
                if settings[:filter][:choices].is_a?(Array)
                  concat @template.select_tag(name, @template.options_for_select([''] + settings[:filter][:choices], value))
                else
                  concat @template.text_field_tag(name, value)
                end
                concat '</div>'
              end
            end
            concat '<input type="submit" value="Search"/>' if search_button
            concat '</form></div>'

            concat '<div style="clear:both">&nbsp;</div>'
          end


          def title_row
            concat '<tr>'
            @list_settings.methods.each do |method, settings|
              accessor = ListFor::Helper::ListSettings.list_method_to_accessor(method)

              heading = settings[:alias]
              heading << " " + @template.image_tag((@options[:sort_reverse] ? "down" : "up")+".png", :class => "icon") if accessor == @options[:sort_accessor]

              uri_copy = add_to_uri(@options[:uri], :list_for => {@options[:name].to_sym => {:sort => accessor, :page => @options[:page].to_s, :reverse => ((!@options[:sort_reverse] && accessor == @options[:sort_accessor]) ? "1" : "0")}})
              concat @template.content_tag(:th) do
                 if @options[:update]
                   query = uri_copy.query
                   uri_copy.query = nil
                   link_to_remote(heading, :with => "'#{query}'", :method => @options[:method], :url => uri_copy.to_s, :update => @options[:update])
                 else
                   link_to(heading, uri_copy.to_s)
                 end
              end
            end
            concat '<th>&nbsp;</th>' if @list_settings.actions?
            concat '</tr>'
          end

          def list(&block)
            #Title row
             concat '<table class="list" cellspacing="0" cellpadding="0">'

             title_row

             @collection = make_paginate_object(@collection, @options[:page], @options[:per_page])
             @collection.each do |item|
               concat '<tr class="'+@template.cycle('even', 'odd', :name => "list_for_#{@options[:name]}")+'">'
                yield ListRow.new(item, @options[:filters])
               concat '</tr>'
             end
             concat '</table>'

             concat(@template.will_paginate(@collection, 
               :param_name => "list_for[#{@options[:name]}][page]", 
               :params => {:list_for => {@options[:name].to_sym => {
                 :sort => @options[:sort_accessor], 
                 :reverse => @options[:sort_reverse].to_s,
                 :filters => @options[:filters]
               }}},
               :renderer => ListFor::Helper::LinkRenderer,
               :update => @options[:update],
               :url => @options[:url],
               :method => @options[:method]).to_s)
          end
        end
      end
    end
  end
end