require 'test_helper'

class NameMappingsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:name_mappings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create name_mapping" do
    assert_difference('NameMapping.count') do
      post :create, :name_mapping => { }
    end

    assert_redirected_to name_mapping_path(assigns(:name_mapping))
  end

  test "should show name_mapping" do
    get :show, :id => name_mappings(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => name_mappings(:one).to_param
    assert_response :success
  end

  test "should update name_mapping" do
    put :update, :id => name_mappings(:one).to_param, :name_mapping => { }
    assert_redirected_to name_mapping_path(assigns(:name_mapping))
  end

  test "should destroy name_mapping" do
    assert_difference('NameMapping.count', -1) do
      delete :destroy, :id => name_mappings(:one).to_param
    end

    assert_redirected_to name_mappings_path
  end
end
