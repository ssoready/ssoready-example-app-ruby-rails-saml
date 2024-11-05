require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get home_index_url
    assert_response :success
  end

  test "should get saml_redirect" do
    get home_saml_redirect_url
    assert_response :success
  end

  test "should get ssoready_callback" do
    get home_ssoready_callback_url
    assert_response :success
  end

  test "should get logout" do
    get home_logout_url
    assert_response :success
  end
end
