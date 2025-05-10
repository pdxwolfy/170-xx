#!/usr/bin/env ruby
# Copyright (c) 2016 Pete Hanson
# frozen_string_literal: true

require_relative 'test_helpers'

#------------------------------------------------------------------------------

describe File.basename(__FILE__).to_s do
  include TestHelpers

  eval TestHelpers.setup_code # rubocop:disable Eval

  def get_file_new session = admin_session
    get Route::FILE_NEW, {}, session
  end

  describe with_id('file creation page') do
    before do
      get_file_new
    end

    it 'shows an HTML page' do
      must_show_html Route::FILE_NEW
    end

    it 'tells user to add a new document' do
      text.must_include 'Add a new document:'
    end

    describe with_id('the file creation form') do
      before do
        @form = select_one html, 'form'
      end

      it "posts to #{Route::FILE_NEW}" do
        @form.must_be_form 'post', Route::FILE_NEW
      end

      it 'has an empty input box for new file name' do
        input = select_one @form, 'input[name="name"]'
        input.must_be_input type: 'text', value: ''
      end

      it 'has a create document button' do
        input = select_one @form, 'input[type="submit"]'
        input.must_be_input type: 'submit', value: 'Create Document'
      end
    end
  end

  #----------------------------------------------------------------------------

  describe with_id('must be logged in') do
    it 'has an error message' do
      get_file_new({})
      session.must_have_error :must_be_signed_in
    end
  end
end
