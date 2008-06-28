module ListFor
  module Helper
    class ListRowBase
      def initialize
        @actions = false
        @methods = ActiveSupport::OrderedHash.new
      end

      def column(method, options = {}, &block)
        nil
      end

      def actions(&block)
        nil
      end
      
      def url(&block)
        nil
      end
      
      def self.list_method_to_accessor(method)
        if method.is_a? Array
          method.collect{|m| m.to_s}.join('.')
        else
          method.to_s
        end
      end
    end
  end
end