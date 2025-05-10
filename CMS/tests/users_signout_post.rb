#!/usr/bin/env ruby
# Copyright (c) 2016 Pete Hanson
# frozen_string_literal: true

require_relative 'test_helpers'

#------------------------------------------------------------------------------

describe File.basename(__FILE__).to_s do
  include TestHelpers

  eval TestHelpers.setup_code # rubocop:disable Eval

  def post_users_signout
    post Route::USERS_SIGNOUT
  end

  describe with_id('signing out') do
    before do
      get Route::INDEX, {}, admin_session
    end

    it 'knows who we are' do
      session[:username].must_equal TestMode::Admin::USERNAME
    end

    describe with_id('posting the signout') do
      before do
        post_users_signout
        get last_response.location
      end

      it 'has a completion message' do
        text.must_include @message[:signed_out]
      end

      it 'has a signin button' do
        @link = select_one html, 'a#signin'
        button = select_one @link, 'button'
        button.must_be_button 'Sign In', type: 'submit'
      end

      it 'has a signup button' do
        @link = select_one html, 'a#signup'
        button = select_one @link, 'button'
        button.must_be_button 'Sign Up', type: 'submit'
      end

      it 'does not have a signout button' do
        select_none html, 'form#signout'
        select_none html, 'a#signout'
      end
    end
  end
end
