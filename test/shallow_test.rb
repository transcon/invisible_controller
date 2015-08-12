require "test_helper"
class ShallowModelsController < InvisibleController::Base
  belongs_to :test_route_model, shallow: true
end
class ShallowTest <  ActionDispatch::IntegrationTest
  def setup
    FlyingTable.create(test_route_model: {name: :string},shallow_model: {name: :string, test_route_model_id: :integer})
    TestRouteModel.has_many :shallow_models
    ShallowModel.belongs_to  :test_route_model
    @test_route_model  = TestRouteModel.create(name: 'test')
    @shallow_model = @test_route_model.shallow_models.create
    @params = {test_route_model_id: @test_route_model.id, format: :json}
  end
  def teardown
    FlyingTable.destroy(:test_route_model,:shallow_model)
  end
  def test_index
    get test_route_model_shallow_models_path(@params)
    assert_response :success
    assert_equal response.body, @test_route_model.shallow_models.to_json
  end
  def test_new
    get new_test_route_model_shallow_model_path(@params)
    assert_response :success
    assert_equal @test_route_model.shallow_models.new.to_json, response.body
  end
  def test_create
    count = @test_route_model.shallow_models.count
    post test_route_model_shallow_models_path(@params)
    assert_response :success
    assert_equal @test_route_model.shallow_models.count, count + 1
  end
  def test_show
    @params[:id] = @shallow_model.id
    get shallow_model_path(@params)
    assert_response :success
    assert_equal response.body, @shallow_model.to_json
  end
  def test_edit
    @params[:id] = @shallow_model.id
    get edit_shallow_model_path(@params)
    assert_response :success
    assert_equal response.body, @shallow_model.to_json
  end
  def test_update
    @params[:id] = @shallow_model.id
    @params[:shallow_model] = {name: 'something else'}
    put shallow_model_path(@params)
    assert_response :success
    assert_equal @shallow_model.reload.name, 'something else'
  end
  def test_destroy
    @params[:id] = @shallow_model.id
    delete shallow_model_path(@params)
    assert_response :success
    assert_raises(ActiveRecord::RecordNotFound) {@shallow_model.reload}
  end
end
