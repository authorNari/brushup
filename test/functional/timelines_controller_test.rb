require File.join(File.dirname(__FILE__), '../test_helper')

class TimelinesControllerTest < ActionController::TestCase
  def setup
    login_as(:nari)
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
    users(:nari).reminders.each{|r| r.tag_list = "hoge fuge"}
    users(:nari).reminders.each(&:save!)
    
    get :list, :tag => "hoge"
    
    assert_response :success
    assert_not_nil assigns(:reminders)
    assigns(:reminders).each do |r|
      assert_equal true, r.tag_list.include?("hoge")
    end
    
    assert_select "div#crumbs a", I18n.t(:list, :scope => [:controller, :timelines])
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
