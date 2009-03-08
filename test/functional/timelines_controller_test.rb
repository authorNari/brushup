require File.join(File.dirname(__FILE__), '../test_helper')

class TimelinesControllerTest < ActionController::TestCase
  def setup
    @user = users(:nari)
    @request.session[:user_id] = @user
    RemindersController.skip_filter :set_jumpto
  end
  
  test "should get index" do
    get :index
    assert_response :redirect
  end

  test "should get list" do
    get :list
    assert_response :success
    assert_not_nil assigns(:reminders)
  end

  test "should get list with tag" do
    @user.reminders.each{|r| r.tag_list = "hoge fuge"}
    @user.reminders.each(&:save!)
    get :list, :tag => "hoge"
    assert_response :success
    assert_not_nil assigns(:reminders)
    assigns(:reminders).each do |r|
      assert_equal true, r.tag_list.include?("hoge")
    end
  end

  test "should show" do
    get :show, :id => reminders(:learned_remined_1).id
    assert_response :success
  end
  
  test "should get today" do
    get :today
    assert_not_nil assigns(:reminders)
    assert_response :success
    assert_template "index"
   end
end
