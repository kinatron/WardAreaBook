require 'test_helper'
require 'test_helper'

class ActionItemsControllerTest < ActionController::TestCase

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
    assert_not_nil assigns(:action_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create action_item" do
    @request.env["HTTP_REFERER"] = action_items_path
    assert_difference('ActionItem.count') do
      post :create, :action_item => {:person_id=> people(:one).id}
    end

    assert_redirected_to action_items_path
  end

  test "should show action_item" do
    get :show, :id => action_items(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => action_items(:one).to_param
    assert_response :success
  end

  test "should update action_item" do
    #TODO I'm not sure how to do this one.
    #put :update, :id => action_items(:one).to_param, :action_item => {:comment=>"Hello Hal" }
    #assert_redirected_to action_item_path(assigns(:action_item))
  end

  test "should destroy action_item" do
    @request.env["HTTP_REFERER"] = action_items_path
    assert_difference('ActionItem.count', -1) do
      delete :destroy, :id => action_items(:one).to_param
    end

    assert_redirected_to action_items_path
  end
end
