#!/usr/bin/env ruby
# Copyright (c) 2016 Pete Hanson
# frozen_string_literal: true

require_relative 'test_helpers'

#------------------------------------------------------------------------------

describe File.basename(__FILE__).to_s do
  include TestHelpers

  eval TestHelpers.setup_code # rubocop:disable Eval

  def post_users_signup username, password
    @username = username
    @password = password
    post Route::USERS_SIGNUP, username: @username, password: @password
  end

  #----------------------------------------------------------------------------

  describe with_id('register user') do
    before do
      post_users_signup 'xyzzy', 'forget me'
    end

    it 'redirects to login page' do
      must_redirect_to Route::USERS_SIGNIN
    end

    it 'it tells the user to login' do
      session.must_have_message :account_created
    end

    it 'can authenticate new user' do
      authenticate?(@username, @password).must_equal true
    end

    it "won't accept bad password" do
      authenticate?(@username, @password + 'x').must_equal false
    end
  end

  #----------------------------------------------------------------------------

  describe with_id('missing username handling') do
    before do
      post_users_signup '', 'forget me'
    end

    it 'returns an Unprocessable (422) status' do
      last_response.must_be :unprocessable?
    end

    it 'redisplays the original page' do
      localpath.must_equal Route::USERS_SIGNUP
    end

    it 'does not know who we are' do
      session[:username].must_be_nil
    end

    it 'has an error message' do
      session.must_have_error :missing_username
    end

    it 'forgot the entered password' do
      input = select_one html, 'form input[name="password"]'
      input.must_be_input type: 'password', value: ''
    end
  end

  #----------------------------------------------------------------------------

  describe with_id('missing password handling') do
    before do
      post_users_signup 'xyzzy', ''
    end

    it 'returns an Unprocessable (422) status' do
      last_response.must_be :unprocessable?
    end

    it 'redisplays the original page' do
      localpath.must_equal Route::USERS_SIGNUP
    end

    it 'does not know who we are' do
      session[:username].must_be_nil
    end

    it 'has an error message' do
      session.must_have_error :missing_password
    end

    it 'forgot the entered password' do
      input = select_one html, 'form input[name="password"]'
      input.must_be_input type: 'password', value: ''
    end

    it 'did not forget the entered username' do
      input = select_one html, 'form input[name="username"]'
      input.must_be_input type: 'text', value: @username
    end
  end

  #----------------------------------------------------------------------------

  describe with_id('bad password handling') do
    before do
      post_users_signup 'abc', '4score'
    end

    it 'returns an Unprocessable (422) status' do
      last_response.must_be :unprocessable?
    end

    it 'redisplays the original page' do
      localpath.must_equal Route::USERS_SIGNUP
    end

    it 'does not know who we are' do
      session[:username].must_be_nil
    end

    it 'has an error message' do
      session.must_have_error :password_too_short
    end

    it 'forgot the entered password' do
      input = select_one html, 'form input[name="password"]'
      input.must_be_input type: 'password', value: ''
    end

    it 'did not forget the entered username' do
      input = select_one html, 'form input[name="username"]'
      input.must_be_input type: 'text', value: @username
    end
  end
end
