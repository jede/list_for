module ListFor
  module Helper
    class ListSettings < ListFor::Helper::ListRowBase
      def initialize
        @actions = false
        @methods = ActiveSupport::OrderedHash.new
      end

      def column(method, options = {}, &block)
        options[:alias] = (method.is_a?(Array) ? method.first : method).to_s.humanize unless options[:alias]
        options[:accessor] = (options[:sort_using] || list_method_to_method(method)).to_s
        @methods[method] = options
        nil
      end

      def actions(label = "", &block)
        @methods["action_#{label}_#{rand}"] = {
          :alias => label,
          :is_heading => true
        }
        @actions = true
        nil
      end
      
      def row(&block)
        @row_options_block = block
        nil
      end
      
      def attributes_for(item, attributes = {})
        @row_options_block.call(attributes, item) if @row_options_block
        attributes.collect{|key, value| "#{key}=\"#{value}\""}.join(" ")
      end
      
      def actions?
        @actions
      end

      def aliases
        @methods.values
      end

      def methods
        @methods
      end

      def accessors
        @methods.keys.collect{|m| list_method_to_accessor(m)}
      end
      
      def uses_accessor?(accessor)
        accessors.include?(accessor)
      end
      
      def list_method_to_accessor(method)
        if @methods[method].nil?
          list_method_to_method(method)
        else
          @methods[method][:accessor].to_s
        end
      end
      
      def list_method_to_method(method)
        method = method.split('.') if method.is_a?(String)
        
        if method.is_a? Array
          method.collect{|m| m.to_s}.join('.')
        else
          method.to_s
        end
        
      end
      
    end
  end
end