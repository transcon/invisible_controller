require "test_helper"
class InvisibleControllerTest <  ActionDispatch::IntegrationTest
  def setup
    FlyingTable.create(test_route_model: {name: :string})
    @test_case = TestRouteModel.create(name: 'test')
    @params = {format: :json}
  end
  def teardown
    FlyingTable.destroy(:test_route_model)
  end
  def test_index
    get test_route_models_path(@params)
    assert_response :success
    assert_equal response.body, TestRouteModel.all.to_json
  end
  def test_new
    get new_test_route_model_path(@params)
    assert_response :success
    assert_equal TestRouteModel.new.to_json, response.body
  end
  def test_create
    count = TestRouteModel.count
    post test_route_models_path(@params)
    assert_response :success
    assert_equal TestRouteModel.count, count + 1
  end
  def test_show
    @params[:id] = @test_case.id
    get test_route_model_path(@params)
    assert_response :success
    assert_equal response.body, @test_case.to_json
  end
  def test_edit
    @params[:id] = @test_case.id
    get edit_test_route_model_path(@params)
    assert_response :success
    assert_equal response.body, @test_case.to_json
  end
  def test_update
    @params[:id] = @test_case.id
    @params[:test_route_model] = {name: 'something else'}
    put test_route_model_path(@params)
    assert_response :success
    assert_equal @test_case.reload.name, 'something else'
  end
  def test_destroy
    @params[:id] = @test_case.id
    delete test_route_model_path(@params)
    assert_response :success
    assert_raises(ActiveRecord::RecordNotFound) {@test_case.reload}
  end
end
