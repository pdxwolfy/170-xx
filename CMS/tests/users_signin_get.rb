#!/usr/bin/env ruby
# Copyright (c) 2016 Pete Hanson
# frozen_string_literal: true

require_relative 'test_helpers'

#------------------------------------------------------------------------------

describe File.basename(__FILE__).to_s do
  include TestHelpers

  eval TestHelpers.setup_code # rubocop:disable Eval

  def get_users_signin # rubocop:disable AccessorMethodName
    get Route::USERS_SIGNIN
  end

  describe with_id('signin page') do
    before do
      get_users_signin
    end

    it 'shows an HTML page' do
      must_show_html Route::USERS_SIGNIN
    end

    it 'tells the user to sign in' do
      text.must_include 'Please sign in:'
    end

    describe with_id('the signin form') do
      before do
        @form = select_one html, 'form'
      end

      it "POSTs to #{Route::USERS_SIGNIN}" do
        @form.must_be_form 'post', Route::USERS_SIGNIN
      end

      it 'has input field for username' do
        input = select_one @form, 'input[name="username"]'
        input.must_be_input type: 'text', value: ''
      end

      it 'has input field for password' do
        input = select_one @form, 'input[name="password"]'
        input.must_be_input type: 'password', value: ''
      end

      it 'has sign in button' do
        input = select_one @form, 'input[type="submit"]'
        input.must_be_input value: 'Sign In'
      end
    end
  end
end
