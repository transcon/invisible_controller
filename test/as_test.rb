require "test_helper"
class AsModelsController < InvisibleController::Base
  belongs_to :test_route_model, shallow: true, as: :foos
end
class AsTest <  ActionDispatch::IntegrationTest
  def setup
    FlyingTable.create(test_route_model: {name: :string},as_model: {name: :string, test_route_model_id: :integer})
    TestRouteModel.has_many :foos, class_name: AsModel
    AsModel.belongs_to  :test_route_model
    @test_route_model  = TestRouteModel.create(name: 'test')
    @as_model = @test_route_model.foos.create
    @params = {test_route_model_id: @test_route_model.id, format: :json}
  end
  def teardown
    FlyingTable.destroy(:test_route_model,:as_model)
  end
  def test_index
    get test_route_model_as_models_path(@params)
    assert_response :success
    assert_equal response.body, @test_route_model.foos.to_json
  end
  def test_new
    get new_test_route_model_as_model_path(@params)
    assert_response :success
    assert_equal @test_route_model.foos.new.to_json, response.body
  end
  def test_create
    count = @test_route_model.foos.count
    post test_route_model_as_models_path(@params)
    assert_response :success
    assert_equal @test_route_model.foos.count, count + 1
  end
  def test_show
    @params[:id] = @as_model.id
    get as_model_path(@params)
    assert_response :success
    assert_equal response.body, @as_model.to_json
  end
  def test_edit
    @params[:id] = @as_model.id
    get edit_as_model_path(@params)
    assert_response :success
    assert_equal response.body, @as_model.to_json
  end
  def test_update
    @params[:id] = @as_model.id
    @params[:as_model] = {name: 'something else'}
    put as_model_path(@params)
    assert_response :success
    assert_equal @as_model.reload.name, 'something else'
  end
  def test_destroy
    @params[:id] = @as_model.id
    delete as_model_path(@params)
    assert_response :success
    assert_raises(ActiveRecord::RecordNotFound) {@as_model.reload}
  end
end
