require File.join(File.dirname(__FILE__), '../test_helper')

class RemindersControllerTest < ActionController::TestCase
  def setup
    login_as(:nari)
  end
  
  test "should get index" do
    get :index, :user => users(:nari).login
    assert_response :redirect
  end

  test "should get list" do
    get :list, :user => users(:nari).login
    assert_response :success
    assert_not_nil assigns(:reminders)
  end

  test "should get list with tag" do
    users(:nari).reminders.each{|r| r.tag_list = "hoge fuge"}
    users(:nari).reminders.each(&:save!)
    get :list, :user => users(:nari).login, :tag => "hoge"
    assert_response :success
    assert_not_nil assigns(:reminders)
    assigns(:reminders).each do |r|
      assert_equal true, r.tag_list.include?("hoge")
    end
  end

  test "should get new" do
    get :new, :user => users(:nari).login
    assert_response :success
  end

  test "should get new with bookmarklet" do
    get :new, :mode => "confirm"
    assert_response :success
  end

  test "should create" do
    assert_difference('Reminder.count') do
      post :create, :reminder => {:title => "new", :body => "body"}, :user => users(:nari).login
    end

    assert_redirected_to :action => :confirm_create, :id => assigns(:reminder).id, :user => users(:nari).login
  end

  test "should create with bookmarklet" do
    assert_difference('Reminder.count') do
      post :create, :reminder => {:title => "new", :body => "body"}, :mode => "confirm", :user => users(:nari).login
    end

    assert_template "share/autoclose.html.erb"
  end

  test "should create fail" do
    assert_difference('Reminder.count', 0) do
      post :create, :reminder => {:title => nil}, :user => users(:nari).login
    end

    assert_template 'new'
  end

  test "should show" do
    get :show, :user => users(:nari).login, :id => reminders(:learned_remined_1).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :user => users(:nari).login, :id => reminders(:learned_remined_1).id
    assert_response :success
  end

  test "should get edit fail with authority" do
    get :edit, :id => reminders(:learned_remined_1).id
    assert_not_nil flash[:notice]
    assert_response :redirect
  end

  test "should update" do
    next_date = reminders(:list_reminder).next_learn_date
    put :update, :id => reminders(:list_reminder).id, :reminder => {:title => "update" }, :user => users(:nari).login
    assert_equal next_date, assigns(:reminder).next_learn_date
    assert_not_nil assigns(:reminder)
    assert_redirected_to :action => :confirm_update, :id => assigns(:reminder).id, :user => users(:nari).login
  end

  test "should update fail" do
    put :update, :id => reminders(:learned_remined_1).id, :reminder => {:title => nil}, :user => users(:nari).login
    assert_template 'edit'
  end

  test "should destroy" do
    assert_difference('Reminder.count', -1) do
      delete :destroy, :id => reminders(:learned_remined_1).id, :user => users(:nari).login
    end

    assert_redirected_to :user => users(:nari).login
   end

  test "should get today" do
    get :today, :user => users(:nari).login
    assert_not_nil assigns(:reminders)
    assert_not_nil assigns(:show_reminder_detail)
    assert_response :success
    assert_template "index"
   end

  test "should get completed" do
    get :completed, :user => users(:nari).login
    assert_not_nil assigns(:reminders)
    assert_response :success
    assert_template "index"
  end

  test "should get copy" do
    assert_difference(["Reminder.count"]) do
      get :copy, :user => users(:aaron).login, :id => reminders(:learned_remined_1).id
    end
    assert_not_nil flash[:notice]
    assert_response :redirect
    assert_redirected_to :user => users(:nari).login, :action => :list
  end
  
  test "should get copy fail" do
    assert_difference(["Reminder.count"], 0) do
      get :copy, :user => users(:aaron).login, :id => reminders(:deep_clone_fail).id
    end
    assert_not_nil flash[:error]
    assert_response :redirect
  end

  test "should get check" do
    get :check, :id => reminders(:learned_remined_1).id, :user => users(:nari).login
    assert_response :redirect
    assert_redirected_to :action => :today, :user => users(:nari).login
  end

  test "should xhr check" do
    xhr :get, :check, :id => reminders(:learned_remined_1).id, :user => users(:nari).login
    assert_select_rjs :replace, "reminder_#{reminders(:learned_remined_1).id}"
  end

  test "should authorize fail" do
    get :edit, :user => users(:aaron).login
    assert_equal I18n.t("permission_denied", :scope => :notice), flash[:notice]
    assert_redirected_to openid_path
  end

  test "should session expired" do
    RemindersController.class_eval do
      expires_session :time => 1.second, :redirect_to => '/'
    end
    get :index, :user => users(:nari).login
    sleep 2
    get :index, :user => users(:nari).login
    
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
