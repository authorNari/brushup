require File.join(File.dirname(__FILE__), '../test_helper')

class SessionsControllerTest < ActionController::TestCase
  def setup
    login_as(:nari)
    SessionsController.class_eval do
      def authenticate(identity_url = "")
        after_autenticate(true, params[:openid_url], "OK", "nickname" => "hoge")
      end
    end
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
    assert_redirected_to "/#{assigns(:user).login}/sessions/edit"
  end
  
  test "shuold create fail" do
    @request.session[:user_id] = nil
    post :create, :user => users(:nari).id
    assert_redirected_to sessions_path
  end

  test "shuold create fail with exception" do
    SessionsController.class_eval do
      def authenticate(identity_url = "")
        raise ActiveRecord::RecordNotSaved, "Error"
      end
    end
    @request.session[:user_id] = nil
    post :create, :user => users(:nari).id, :openid_url => users(:nari).openid_url
    assert_not_nil flash[:notice]
    assert_redirected_to :action => "index"
  end

  test "shuold get edit" do
    get :edit, :user => users(:nari).login
    assert_not_nil assigns(:user)
  end

  test "shuold update" do
    get :update, :user => users(:nari).login, :edit_user => {:login => "update"}
    assert_equal "update", assigns(:user).login
  end

  test "shuold update fail" do
    get :update, :user => users(:nari).login, :edit_user => {:login => "aaron"}

    assert_template "edit"
    assert_equal "aaron", assigns(:user).login
    assert_not_equal "aaron", @controller.instance_eval("@current_user.login")
  end

  test "shuold destroy" do
    delete :destroy, :user => users(:nari).login
    assert_nil session[:user_id]
    assert_redirected_to "/login"
  end
  
  test "should_login_with_cookie" do
    get :create, :openid_url => users(:nari).openid_url
    assert_not_nil cookies["brushup_auth_token"]

    # cookie copy
    users(:nari).remember_token = cookies["brushup_auth_token"][0]
    @request.cookies["brushup_auth_token"] = cookie_for(:nari)

    # session clear
    @request.session[:user_id] = nil
    @controller.instance_eval("@current_user = nil")
    
    get :index
    assert @controller.send(:logged_in?)
  end
  
  protected
    def create_user(options = {})
      post :signup, :user => { :login => 'quire', :email => 'quire@example.com', 
        :password => 'quire', :password_confirmation => 'quire' }.merge(options)
    end
    
    def auth_token(token)
      CGI::Cookie.new('name' => 'brushup_auth_token', 'value' => token)
    end
    
    def cookie_for(user)
      auth_token users(user).remember_token
    end
end
