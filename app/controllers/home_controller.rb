class HomeController < ApplicationController
  def index
    # This demo just renders plain old HTML with no client-side JavaScript. This
    # is only to keep the demo minimal. SSOReady works with any frontend stack
    # or framework you use.
    #
    # This demo keeps the HTML minimal to keep things as simple as possible
    # here.
    #
    # The view for the index page lives in views/home/index.html.erb
  end

  # This is the page users visit when they click on the "Log out" link in this
  # demo app. It just uses devise's builtin sign_out method.
  #
  # SSOReady doesn't impose any constraints on how your app's sessions work.
  def logout
    sign_out
    redirect_to("/")
  end

  # This is the action users visit when they submit the "Log in with SAML" form
  # in this demo app.
  def saml_redirect
    # To start a SAML login, you need to redirect your user to their employer's
    # particular Identity Provider. This is called "initiating" the SAML login.
    #
    # Use `saml.get_saml_redirect_url` to initiate a SAML login.
    get_redirect_result = ssoready.saml.get_saml_redirect_url(
      # organization_external_id is how you tell SSOReady which company's
      # identity provider you want to redirect to.
      #
      # In this demo, we identify companies using their domain. This code
      # converts "john.doe@example.com" into "example.com".
      organization_external_id: params[:email].split("@").last
    )

    # `saml.get_saml_redirect_url` returns an object like this:
    #
    # GetSamlRedirectUrlResponse(redirect_url: "https://...")
    #
    # To initiate a SAML login, you redirect the user to that redirect_url.
    redirect_to(get_redirect_result.redirect_url, allow_other_host: true)
  end

  # This is the action SSOReady redirects your users to when they've
  # successfully logged in with SAML.
  def ssoready_callback
    # SSOReady gives you a one-time SAML access code under
    # ?saml_access_code=saml_access_code_... in the callback URL's query
    # parameters.
    #
    # You redeem that SAML access code using `saml.redeem_saml_access_code`,
    # which gives you back the user's email address. Then, it's your job to log
    # the user in as that email.
    redeem_result = ssoready.saml.redeem_saml_access_code(
      saml_access_code: params[:saml_access_code]
    )

    # SSOReady works with any stack or session technology you use. In this demo
    # app, we use devise. We upsert a user by email, and then log in as them.
    user = User.find_or_create_by(email: redeem_result.email)
    sign_in(user)
    redirect_to("/")
  end

  private

  def ssoready
    # Do not hard-code or leak your SSOReady API key in production!
    #
    # In production, instead you should configure a secret SSOREADY_API_KEY
    # environment variable. The SSOReady SDK automatically loads an API key from
    # SSOREADY_API_KEY.
    #
    # This key is hard-coded here for the convenience of logging into a test
    # app, which is hard-coded to run on http://localhost:3000. It's only
    # because of this very specific set of constraints that it's acceptable to
    # hard-code and publicly leak this API key.
    SSOReady::Client.new(api_key: "ssoready_sk_8yy14tqupbgvoc1l9l3ik7ldj")
  end
end
