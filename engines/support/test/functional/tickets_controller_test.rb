require 'test_helper'

#
# Tests for the basic actions in the TicketsController
#
# Also see
# TicketCommentsTest
# TicketsListTest
#
# for detailed functional tests for comments and index action.
#
class TicketsControllerTest < ActionController::TestCase

  teardown do
    # destroy all tickets that were created during the test
    Ticket.all.each{|t| t.destroy}
  end

  test "should get index if logged in" do
    login
    get :index
    assert_response :success
    assert_not_nil assigns(:tickets)
  end

  test "no index if not logged in" do
    get :index
    assert_response :redirect
    assert_nil assigns(:tickets)
  end

  test "should get new" do
    get :new
    assert_equal Ticket, assigns(:ticket).class
    assert_response :success
  end

  test "unauthenticated tickets are visible" do
    ticket = find_record :ticket, :created_by => nil
    get :show, :id => ticket.id
    assert_response :success
  end

  test "user tickets are not visible without login" do
    user = find_record :user
    ticket = find_record :ticket, :created_by => user.id
    get :show, :id => ticket.id
    assert_response :redirect
    assert_redirected_to login_url
  end

  test "user tickets are visible to creator" do
    user = find_record :user
    ticket = find_record :ticket, :created_by => user.id
    login user
    get :show, :id => ticket.id
    assert_response :success
  end

  test "other users tickets are not visible" do
    other_user = find_record :user
    ticket = find_record :ticket, :created_by => other_user.id
    login
    get :show, :id => ticket.id
    assert_response :redirect
    assert_redirected_to home_url
  end

  test "should create unauthenticated ticket" do
    params = {:subject => "unauth ticket test subject", :comments_attributes => {"0" => {"body" =>"body of test ticket"}}}

    assert_difference('Ticket.count') do
      post :create, :ticket => params
    end

    assert_response :redirect
    assert_nil assigns(:ticket).created_by

    assert_equal 1, assigns(:ticket).comments.count
    assert_nil assigns(:ticket).comments.first.posted_by

  end

  test "handle invalid ticket" do
    params = {:subject => "unauth ticket test subject", :comments_attributes => {"0" => {"body" =>"body of test ticket"}}, :email => 'a'}

    assert_no_difference('Ticket.count') do
      post :create, :ticket => params
    end

    assert_template :new
    assert_equal params[:subject], assigns(:ticket).subject
  end

  test "should create authenticated ticket" do

    params = {:subject => "auth ticket test subject",:email => "", :comments_attributes => {"0" => {"body" =>"body of test ticket"}}}

    login

    assert_difference('Ticket.count') do
      post :create, :ticket => params
    end

    assert_response :redirect

    assert_not_nil assigns(:ticket).created_by
    assert_equal assigns(:ticket).created_by, @current_user.id
    assert_equal "", assigns(:ticket).email

    assert_equal 1, assigns(:ticket).comments.count
    assert_not_nil assigns(:ticket).comments.first.posted_by
    assert_equal assigns(:ticket).comments.first.posted_by, @current_user.id
  end
end

