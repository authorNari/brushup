require File.join(File.dirname(__FILE__), '../test_helper')

class RemindersControllerTest < ActionController::TestCase
  def setup
    @user = users(:nari)
    @request.session[:user_id] = @user
    RemindersController.skip_filter :set_jumpto
  end
  
  test "should get index" do
    get :index, :user => @user.login
    assert_response :redirect
  end

  test "should get list" do
    get :list, :user => @user.login
    assert_response :success
    assert_not_nil assigns(:reminders)
  end

  test "should get list with tag" do
    @user.reminders.each{|r| r.tag_list = "hoge fuge"}
    @user.reminders.each(&:save!)
    get :list, :user => @user.login, :tag => "hoge"
    assert_response :success
    assert_not_nil assigns(:reminders)
    assigns(:reminders).each do |r|
      assert_equal true, r.tag_list.include?("hoge")
    end
  end

  test "should get new" do
    get :new, :user => @user.login
    assert_response :success
  end

  test "should create" do
    assert_difference('Reminder.count') do
      post :create, :reminder => {:title => "new", :body => "body"}, :user => @user.login
    end

    assert_redirected_to :action => :list, :user => @user.login
  end

  test "should create auto close" do
    assert_difference('Reminder.count') do
      post :create, :reminder => {:title => "new", :body => "body"}, :user => @user.login, :mode => "confirm"
    end

    assert_template "share/autoclose.html.erb"
  end

  test "should create fail" do
    assert_difference('Reminder.count', 0) do
      post :create, :reminder => {:title => nil}, :user => @user.login
    end

    assert_template 'new'
  end

  test "should show" do
    get :show, :user => @user.login, :id => reminders(:learned_remined_1).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :user => @user.login, :id => reminders(:learned_remined_1).id
    assert_response :success
  end

  test "should update" do
    put :update, :id => reminders(:learned_remined_1).id, :reminder => { }, :user => @user.login
    assert_redirected_to :action => :list, :user => @user.login
  end

  test "should update fail" do
    put :update, :id => reminders(:learned_remined_1).id, :reminder => {:title => nil}, :user => @user.login
    assert_template 'edit'
  end

  test "should destroy" do
    assert_difference('Reminder.count', -1) do
      delete :destroy, :id => reminders(:learned_remined_1).id, :user => @user.login
    end

    assert_redirected_to :action => :list, :user => @user.login
   end

  test "should get today" do
    get :today, :user => @user.login
    assert_not_nil assigns(:reminders)
    assert_not_nil assigns(:show_reminder_detail)
    assert_response :success
    assert_template "index"
   end

  test "should get completed" do
    get :completed, :user => @user.login
    assert_not_nil assigns(:reminders)
    assert_response :success
    assert_template "index"
  end

  test "should get check" do
    get :check, :id => reminders(:learned_remined_1).id
    assert_response :redirect
    assert_redirected_to :action => :today, :user => @user.login
  end

  test "should xhr check" do
    xhr :get, :check, :id => reminders(:learned_remined_1).id, :user => @user.login
    assert_select_rjs :replace, "reminder_#{reminders(:learned_remined_1).id}"
  end

  test "should authorize fail" do
    @user = users(:aaron)
    get :edit, :user => @user.login
    assert_equal I18n.t("permission_denied", :scope => :notice), flash[:notice]
    assert_redirected_to openid_path
  end

  test "should session expired" do
    RemindersController.class_eval do
      expires_session :time => 1.second, :redirect_to => '/'
    end
    get :index, :user => @user.login
    sleep 1
    get :index, :user => @user.login
    
    assert_redirected_to '/'
    assert_equal I18n.t(:session_expired, :scope => %w(notice)), flash[:notice]
  end

  test "auto complete for tag name" do
    get :auto_complete_for_tag_name, :tag => {:name => "a"}

    assert_response :success
    assert_select "ul>li" do
      assert_select "li"
    end
  end
end
