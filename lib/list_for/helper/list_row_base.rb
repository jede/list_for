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

      def actions(label = nil, &block)
        nil
      end
      
      def url(&block)
        nil
      end
      
      protected
      
      def eval_concat(str, binding)
        eval "concat(\"#{str}\"#{Rails.version > '2.2.0' ? '' : ', binding'})", binding
      end
      
    end
  end
end