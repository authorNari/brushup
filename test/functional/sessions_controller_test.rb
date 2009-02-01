require File.join(File.dirname(__FILE__), '../test_helper')

class SessionsControllerTest < ActionController::TestCase
  def setup
    @request.session[:user_id] = users(:nari)
  end
  
  test "shuold get index" do
    get :index
    assert_not_nil assigns(:user)
  end

  test "shuold faild create" do
    post :create, :user => users(:nari).id
    assert_redirected_to sessions_path
  end

  test "shuold get edit" do
    get :edit, :user => users(:nari).id
    assert_not_nil assigns(:user)
  end

  test "shuold get update" do
    get :update, :user => users(:nari).id, :edit_user => {:login => "update"}
    assert_equal "update", assigns(:user).login
  end

  
end
