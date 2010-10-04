require 'test_helper'

class CallingsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:callings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create calling" do
    assert_difference('Calling.count') do
      post :create, :calling => { }
    end

    assert_redirected_to calling_path(assigns(:calling))
  end

  test "should show calling" do
    get :show, :id => callings(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => callings(:one).to_param
    assert_response :success
  end

  test "should update calling" do
    put :update, :id => callings(:one).to_param, :calling => { }
    assert_redirected_to calling_path(assigns(:calling))
  end

  test "should destroy calling" do
    assert_difference('Calling.count', -1) do
      delete :destroy, :id => callings(:one).to_param
    end

    assert_redirected_to callings_path
  end
end
