require 'test_helper'

class TeachingRoutesControllerTest < ActionController::TestCase
  def setup
    #TODO this seems a little silly, there's got to be a better way
    get :index, {}, { :user_id => users(:dave).id, 
                      :user_email => 'kinateder@gmail.com', 
                      :expiration => 1.minutes.from_now,
                      :access_level => 3 }
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:teaching_routes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create teaching_route" do
    #assert_difference('TeachingRoute.count') do
    #  post :create, :teaching_route => { }
    #end

#    assert_redirected_to teaching_route_path(assigns(:teaching_route))
  end

  test "should show teaching_route" do
    get :show, :id => teaching_routes(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => teaching_routes(:one).to_param
    assert_response :success
  end

  test "should update teaching_route" do
    put :update, :id => teaching_routes(:one).to_param, :teaching_route => { }
    assert_redirected_to teaching_route_path(assigns(:teaching_route))
  end

  test "should destroy teaching_route" do
    assert_difference('TeachingRoute.count', -1) do
      delete :destroy, :id => teaching_routes(:one).to_param
    end

    assert_redirected_to teaching_routes_path
  end
end
