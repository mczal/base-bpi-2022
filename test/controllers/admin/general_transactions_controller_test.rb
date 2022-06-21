require "test_helper"

class Admin::GeneralTransactionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_general_transactions_index_url
    assert_response :success
  end

  test "should get create" do
    get admin_general_transactions_create_url
    assert_response :success
  end

  test "should get new" do
    get admin_general_transactions_new_url
    assert_response :success
  end

  test "should get edit" do
    get admin_general_transactions_edit_url
    assert_response :success
  end

  test "should get show" do
    get admin_general_transactions_show_url
    assert_response :success
  end

  test "should get destroy" do
    get admin_general_transactions_destroy_url
    assert_response :success
  end
end