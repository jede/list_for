# Include hook code here
require 'will_paginate'
ActionController::Base.class_eval { include ListFor::Extensions::ActionController::InstanceMethods }
ActionController::Base.before_filter :load_list_params
ActionController::Base.helper ListFor::Helper
Array.class_eval { include ListFor::Extensions::Array::InstanceMethods }
TrueClass.class_eval { include ListFor::Extensions::TrueClass::InstanceMethods }
FalseClass.class_eval { include ListFor::Extensions::FalseClass::InstanceMethods }
NilClass.class_eval { include ListFor::Extensions::NilClass::InstanceMethods }
