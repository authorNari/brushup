require File.join(File.dirname(__FILE__), '../test_helper')

class SessionsControllerTest < ActionController::TestCase
  def setup
    @request.session[:user_id] = users(:nari)
  end
  
  test "shuold get index" do
    get :index
    assert_not_nil assigns(:user)
  end

  test "shuold create" do
    @request.session[:user_id] = nil
    post :create, :user => users(:nari).id, :openid_url => users(:nari).openid_url
    assert_not_nil @request.session[:user_id]
    assert_not_nil assigns(:user)
    assert_redirected_to :controller => "reminders", :user => users(:nari).login, :action => :today
  end
  
  test "shuold create to update" do
    @request.session[:user_id] = nil
    post :create, :user => users(:nari).id, :openid_url => "update_url"
    assert_not_nil @request.session[:user_id]
    assert_not_nil assigns(:user)
    assert_redirected_to :action => :edit
  end
  
  test "shuold create fail" do
    @request.session[:user_id] = nil
    post :create, :user => users(:nari).id
    assert_redirected_to sessions_path
  end

  test "shuold get edit" do
    get :edit, :user => users(:nari).id
    assert_not_nil assigns(:user)
  end

  test "shuold update" do
    get :update, :user => users(:nari).id, :edit_user => {:login => "update"}
    assert_equal "update", assigns(:user).login
  end

  test "shuold update fail" do
    get :update, :user => users(:nari).id, :edit_user => {:login => nil}
    assert_template "edit"
  end

  test "shuold destroy" do
    delete :destroy, :user => users(:nari).id
    assert_nil @request.session[:user_id]
    assert_redirected_to openid_path
  end
  
end
