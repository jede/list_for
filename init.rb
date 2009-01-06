# Include hook code here
require 'will_paginate'
Dir.glob(File.join(File.dirname(__FILE__), '/lib/*.rb')).each {|file| require file}
Dir.glob(File.join(File.dirname(__FILE__), '/lib/*/*.rb')).each {|file| require file}
Dir.glob(File.join(File.dirname(__FILE__), '/lib/*/*/*.rb')).each {|file| require file}
Dir.glob(File.join(File.dirname(__FILE__), '/lib/*/*/*/*.rb')).each {|file| require file}
Dir.glob(File.join(File.dirname(__FILE__), '/lib/*/*/*/*/*.rb')).each {|file| require file}

ActiveRecord::Base.extend ListFor::Extensions::ActiveRecord::Base::ClassMethods
ActionController::Base.class_eval { include ListFor::Extensions::ActionController::InstanceMethods }
ActionController::Base.before_filter :load_list_params
ActionController::Base.helper ListFor::Helper
Array.class_eval { include ListFor::Extensions::Array::InstanceMethods }
TrueClass.class_eval { include ListFor::Extensions::TrueClass::InstanceMethods }
FalseClass.class_eval { include ListFor::Extensions::FalseClass::InstanceMethods }
NilClass.class_eval { include ListFor::Extensions::NilClass::InstanceMethods }

begin
  require 'thinking_sphinx'
rescue LoadError
  puts "List for: thinking sphinx not found. Skipping..."
else
  ActiveRecord::Base.send :include, ListFor::Extensions::ThinkingSphinx::ActiveRecord
end

