require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
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
    assert_not_nil assigns(:comments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create comment" do
    assert_difference('Comment.count') do
      post :create, :comment => {:family_id => 1 }
    end

    assert_response :success
    #assert_redirected_to comment_path(assigns(:comment))
  end

  test "should show comment" do
    get :show, :id => comments(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => comments(:one).to_param
    assert_response :success
  end

  test "should update comment" do
    put :update, :id => comments(:one).to_param, :comment => { }

    assert_response :success
    #assert_redirected_to comment_path(assigns(:comment))
  end

  test "should destroy comment" do
    assert_difference('Comment.count', -1) do
      delete :destroy, :id => comments(:one).to_param
    end

    assert_response :success
    #assert_redirected_to comments_path
  end
end
