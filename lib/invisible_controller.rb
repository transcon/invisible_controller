require "active_record"
require "invisible_controller/version"
require "invisible_controller/active_support_override"
require "invisible_controller/active_record_extension"
require "rails/engine"

module InvisibleController
  class Railtie < ::Rails::Engine
    config.inheritted_resources = InvisibleController
  end
end
