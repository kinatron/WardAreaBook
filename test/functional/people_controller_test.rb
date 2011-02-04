require 'test_helper'

class PeopleControllerTest < ActionController::TestCase
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
    assert_not_nil assigns(:people)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create person" do
    assert_difference('Person.count') do
      post :create, :person => { }
    end

    assert_redirected_to person_path(assigns(:person))
  end

  test "should show person" do
    get :show, :id => people(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => people(:one).to_param
    assert_response :success
  end

  test "should update person" do
    put :update, :id => people(:one).to_param, :person => { }
    assert_redirected_to person_path(assigns(:person))
  end

  test "should destroy person" do
    assert_difference('Person.count', -1) do
      delete :destroy, :id => people(:one).to_param
    end

    assert_redirected_to people_path
  end
end
