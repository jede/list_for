module ListFor
  module Helper
    module Support
      def is_will_paginate_collection?(collection)
        collection.is_a?(WillPaginate::Collection)
      end
      
      def is_ultrasphinx_collection?(collection)
        defined?(Ultrasphinx::Search) && collection.is_a?(Ultrasphinx::Search)
      end
      
      def is_will_paginate_compatible?(collection)
        collection.respond_to?(:next_page) &&
        (collection.respond_to?(:offset) || collection.respond_to?(:page_count)) && 
        collection.respond_to?(:previous_page)
      end
    end
  end
end