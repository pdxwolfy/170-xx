#!/usr/bin/env ruby
# Copyright (c) 2016 Pete Hanson
# frozen_string_literal: true

require_relative 'test_helpers'

#------------------------------------------------------------------------------

describe File.basename(__FILE__).to_s do
  include TestHelpers

  eval TestHelpers.setup_code # rubocop:disable Eval

  def get_users_signup # rubocop:disable AccessorMethodName
    get Route::USERS_SIGNUP
  end

  describe with_id('signup page') do
    before do
      get_users_signup
    end

    it 'shows an HTML page' do
      must_show_html Route::USERS_SIGNUP
    end

    it 'tells the user to sign up' do
      text.must_include 'Please choose a login name and password:'
    end

    describe with_id('the signup form') do
      before do
        @form = select_one html, 'form'
      end

      it "POSTs to #{Route::USERS_SIGNUP}" do
        @form.must_be_form 'post', Route::USERS_SIGNUP
      end

      it 'has input field for username' do
        input = select_one @form, 'input[name="username"]'
        input.must_be_input type: 'text', value: ''
      end

      it 'has input field for password' do
        input = select_one @form, 'input[name="password"]'
        input.must_be_input type: 'password', value: ''
      end

      it 'has sign up button' do
        input = select_one @form, 'input[type="submit"]'
        input.must_be_input value: 'Sign Up'
      end
    end
  end
end
