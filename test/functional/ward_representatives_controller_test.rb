require 'test_helper'

class WardRepresentativesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ward_representatives)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ward_representative" do
    assert_difference('WardRepresentative.count') do
      post :create, :ward_representative => { }
    end

    assert_redirected_to ward_representative_path(assigns(:ward_representative))
  end

  test "should show ward_representative" do
    get :show, :id => ward_representatives(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => ward_representatives(:one).to_param
    assert_response :success
  end

  test "should update ward_representative" do
    put :update, :id => ward_representatives(:one).to_param, :ward_representative => { }
    assert_redirected_to ward_representative_path(assigns(:ward_representative))
  end

  test "should destroy ward_representative" do
    assert_difference('WardRepresentative.count', -1) do
      delete :destroy, :id => ward_representatives(:one).to_param
    end

    assert_redirected_to ward_representatives_path
  end
end
