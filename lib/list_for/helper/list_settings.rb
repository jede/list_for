module ListFor
  module Helper
    class ListSettings < ListFor::Helper::ListRowBase
      def initialize
        @actions = false
        @methods = ActiveSupport::OrderedHash.new
      end

      def column(method, options = {}, &block)
        options[:alias] = (method.is_a?(Array) ? method.first : method).to_s.humanize unless options[:alias]
        @methods[method] = options
        nil
      end

      def actions(&block)
        @actions = true
        nil
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
        @methods.keys.collect{|m| ListFor::Helper::ListSettings.list_method_to_accessor(m)}
      end

      def uses_accessor?(accessor)
        accessors.include?(accessor)
      end
    end
  end
end