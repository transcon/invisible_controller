require "test_helper"
class NestedModelsController < InvisibleController::Base
  belongs_to :test_route_model
end
class NestedTest <  ActionDispatch::IntegrationTest
  def setup
    FlyingTable.create(test_route_model: {name: :string},nested_model: {name: :string, test_route_model_id: :integer})
    TestRouteModel.has_many :nested_models
    NestedModel.belongs_to  :test_route_model
    @test_route_model  = TestRouteModel.create(name: 'test')
    @nested_model = @test_route_model.nested_models.create
    @params = {test_route_model_id: @test_route_model.id, format: :json}
  end
  def teardown
    FlyingTable.destroy(:test_route_model,:nested_model)
  end
  def test_index
    get test_route_model_nested_models_path(@params)
    assert_response :success
    assert_equal response.body, @test_route_model.nested_models.to_json
  end
  def test_new
    get new_test_route_model_nested_model_path(@params)
    assert_response :success
    assert_equal @test_route_model.nested_models.new.to_json, response.body
  end
  def test_create
    count = @test_route_model.nested_models.count
    post test_route_model_nested_models_path(@params)
    assert_response :success
    assert_equal @test_route_model.nested_models.count, count + 1
  end
  def test_show
    @params[:id] = @nested_model.id
    get test_route_model_nested_model_path(@params)
    assert_response :success
    assert_equal response.body, @nested_model.to_json
  end
  def test_edit
    @params[:id] = @nested_model.id
    get edit_test_route_model_nested_model_path(@params)
    assert_response :success
    assert_equal response.body, @nested_model.to_json
  end
  def test_update
    @params[:id] = @nested_model.id
    @params[:nested_model] = {name: 'something else'}
    put test_route_model_nested_model_path(@params)
    assert_response :success
    assert_equal @nested_model.reload.name, 'something else'
  end
  def test_destroy
    @params[:id] = @nested_model.id
    delete test_route_model_nested_model_path(@params)
    assert_response :success
    assert_raises(ActiveRecord::RecordNotFound) {@nested_model.reload}
  end
end
