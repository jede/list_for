# Include hook code here
require 'will_paginate'
ActionController::Base.class_eval { include ListFor::ActionController::InstanceMethods }
ActionController::Base.before_filter :load_list_params
ActionController::Base.helper ListForHelper
TrueClass.class_eval { include ListFor::TrueClass::InstanceMethods }
FalseClass.class_eval { include ListFor::FalseClass::InstanceMethods }
NilClass.class_eval { include ListFor::NilClass::InstanceMethods }
