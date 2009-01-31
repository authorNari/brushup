require File.join(File.dirname(__FILE__), '../test_helper')

class RemindersControllerTest < ActionController::TestCase
  def setup
    @user = users(:nari)
    RemindersController.skip_filter :authorize
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

  test "should create reminder" do
    assert_difference('Reminder.count') do
      post :create, :reminder => {:title => "new", :body => "body"}, :user => @user.login
    end

    assert_redirected_to :action => :list, :user => @user.login
  end

  test "should show reminder" do
    get :show, :user => @user.login, :id => reminders(:learned_remined_1).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :user => @user.login, :id => reminders(:learned_remined_1).id
    assert_response :success
  end

  test "should update reminder" do
    put :update, :id => reminders(:learned_remined_1).id, :reminder => { }, :user => @user.login
    assert_redirected_to :action => :list, :user => @user.login
  end

  test "should destroy reminder" do
    assert_difference('Reminder.count', -1) do
      delete :destroy, :id => reminders(:learned_remined_1).id, :user => @user.login
    end

    assert_redirected_to :action => :list, :user => @user.login
  end
end
