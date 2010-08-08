require 'test_helper'

class TeachingRecordsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:teaching_records)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create teaching_record" do
    assert_difference('TeachingRecord.count') do
      post :create, :teaching_record => { }
    end

    assert_redirected_to teaching_record_path(assigns(:teaching_record))
  end

  test "should show teaching_record" do
    get :show, :id => teaching_records(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => teaching_records(:one).to_param
    assert_response :success
  end

  test "should update teaching_record" do
    put :update, :id => teaching_records(:one).to_param, :teaching_record => { }
    assert_redirected_to teaching_record_path(assigns(:teaching_record))
  end

  test "should destroy teaching_record" do
    assert_difference('TeachingRecord.count', -1) do
      delete :destroy, :id => teaching_records(:one).to_param
    end

    assert_redirected_to teaching_records_path
  end
end
