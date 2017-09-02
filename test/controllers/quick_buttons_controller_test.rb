require 'test_helper'

class QuickButtonsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @quick_button = quick_buttons(:one)
  end

  test "should get index" do
    get quick_buttons_url
    assert_response :success
  end

  test "should get new" do
    get new_quick_button_url
    assert_response :success
  end

  test "should create quick_button" do
    assert_difference('QuickButton.count') do
      post quick_buttons_url, params: { quick_button: { description: @quick_button.description, device_uid: @quick_button.device_uid, duration: @quick_button.duration, index_on_device: @quick_button.index_on_device, title: @quick_button.title, user_id: @quick_button.user_id } }
    end

    assert_redirected_to quick_button_url(QuickButton.last)
  end

  test "should show quick_button" do
    get quick_button_url(@quick_button)
    assert_response :success
  end

  test "should get edit" do
    get edit_quick_button_url(@quick_button)
    assert_response :success
  end

  test "should update quick_button" do
    patch quick_button_url(@quick_button), params: { quick_button: { description: @quick_button.description, device_uid: @quick_button.device_uid, duration: @quick_button.duration, index_on_device: @quick_button.index_on_device, title: @quick_button.title, user_id: @quick_button.user_id } }
    assert_redirected_to quick_button_url(@quick_button)
  end

  test "should destroy quick_button" do
    assert_difference('QuickButton.count', -1) do
      delete quick_button_url(@quick_button)
    end

    assert_redirected_to quick_buttons_url
  end
end
