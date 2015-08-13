require 'action_controller'
class ApplicationController < ActionController::Base
end
require 'minitest/autorun'
require 'invisible_controller'
require 'minitest/reporters'
require 'flying_table'
require 'rails'
require 'rails/test_help'
$:.unshift File.expand_path(File.dirname(__FILE__) + '/../app/controllers')
require 'invisible_controller/base'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

module InvisibleControllerTestApplication
  class Application < Rails::Application
    config.secret_key_base = '9147977100352cfc10f35f9e1d2de3451a1592cb09ea5e8d6540556a4d86b045a620e76ecfefd6e6fb7fa68887b1fdc234b180e2831f405baa3705dcd6ff10fd'
  end
end
Rails.logger = Logger.new('.invisible_controller.log')
ActionDispatch.test_app = Rails.application
Rails.application.routes.draw do
  resources :test_route_models do
    resources :nested_models
    resources :shallow_models, shallow: true
    resources :as_models, shallow: true
  end
  root to:   "default#index"
end
