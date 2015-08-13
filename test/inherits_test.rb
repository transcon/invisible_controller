require "test_helper"
class InheritsTest < MiniTest::Test
  def test_base_inherits_from_application_controller
    assert InvisibleController::Base < ApplicationController
  end
end
