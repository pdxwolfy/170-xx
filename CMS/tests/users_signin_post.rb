#!/usr/bin/env ruby
# Copyright (c) 2016 Pete Hanson
# frozen_string_literal: true

require_relative 'test_helpers'

#------------------------------------------------------------------------------

describe File.basename(__FILE__).to_s do
  include TestHelpers

  eval TestHelpers.setup_code # rubocop:disable Eval

  def post_users_signin username, password
    post Route::USERS_SIGNIN, username: username, password: password
  end

  #----------------------------------------------------------------------------

  describe with_id('login as user') do
    TestHelpers.credentials.each do |userinfo|
      describe with_id("#{userinfo.username} login works") do
        before do
          @username = userinfo.username
          post_users_signin userinfo.username, userinfo.raw_password
          get last_response.location
        end

        it 'has welcome message' do
          session.must_have_message :welcome
        end

        it 'knows who we are' do
          session[:username].must_equal userinfo.username
        end

        it 'has signed in message' do
          text.must_include @message[:signed_in_as]
        end

        it 'retains signed in message on new page' do
          get Route::INDEX
          text.must_include @message[:signed_in_as]
        end
      end
    end
  end

  #----------------------------------------------------------------------------

  describe with_id('additional login checks') do
    before do
      user = TestHelpers.credentials.find { |info| info.username == 'wolfy' }
      @username = user.username
      @password = user.raw_password

      post_users_signin @username, @password
      get last_response.location
    end

    describe with_id('signout form') do
      before do
        @form = select_one html, 'form#signout'
      end

      it "POSTs to #{Route::USERS_SIGNOUT}" do
        @form.must_be_form 'post', Route::USERS_SIGNOUT
      end

      it 'has signout button' do
        button = select_one @form, 'button'
        button.must_be_button 'Sign Out', type: 'submit'
      end

      it 'does not have a sign-in button' do
        select_none html, 'form#signin'
        select_none html, 'a#signin'
      end

      it 'does not have a sign-up button' do
        select_none html, 'form#signup'
        select_none html, 'a#signup'
      end
    end
  end

  #----------------------------------------------------------------------------

  describe with_id('bad credentials') do
    BAD_CREDENTIALS = [
      {
        type:     'bad password',
        username: TestMode::Admin::USERNAME,
        password: "x#{TestMode::Admin::PASSWORD}"
      },
      {
        type:     'bad username',
        username: "x#{TestMode::Admin::USERNAME}",
        password: TestMode::Admin::PASSWORD
      }
    ].freeze

    BAD_CREDENTIALS.each do |info|
      describe info[:type] do
        before do
          post_users_signin info[:username], info[:password]
        end

        it 'returns an Unprocessable (422) status' do
          last_response.must_be :unprocessable?
        end

        it 'redisplays the original page' do
          localpath.must_equal Route::USERS_SIGNIN
        end

        it 'does not know who we are' do
          session[:username].must_be_nil
        end

        it 'has an error message' do
          puts session.inspect
          puts session["session_id"].inspect
          puts session["csrf"].inspect
          puts session["tracking"].inspect
          puts session["message"].inspect
          session.must_have_error :invalid_credentials
        end

        it 'retains the entered username' do
          input = select_one html, 'form input[name="username"]'
          input.must_be_input type: 'text', value: info[:username]
        end

        it 'forgot the entered password' do
          input = select_one html, 'form input[name="password"]'
          input.must_be_input type: 'password', value: ''
        end
      end
    end
  end
end
