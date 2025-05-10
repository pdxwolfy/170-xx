#!/usr/bin/env ruby
# Copyright (c) 2016 Pete Hanson
# frozen_string_literal: true

require_relative 'test_helpers'

#------------------------------------------------------------------------------

describe File.basename(__FILE__).to_s do
  include TestHelpers

  eval TestHelpers.setup_code # rubocop:disable Eval

  def get_file_duplicate original_file, session = admin_session
    @file_name = @original_file_name = original_file
    yield if block_given?
    env = { name: @file_name, original: @file_name }
    get Route::FILE_DUPLICATE, env, session
  end

  describe with_id('file duplication page') do
    before do
      get_file_duplicate('abc.txt') { make_file @original_file_name }
    end

    it 'shows an HTML page' do
      query = { name: @file_name, original: @original_file_name }
      must_show_html Route::FILE_DUPLICATE, query: query
    end

    it 'tells user to create a duplicate' do
      text.must_include "Creating duplicate of #{@original_file_name}."
      text.must_include 'Enter name of new file:'
    end

    describe with_id('the file duplication form') do
      before do
        @form = select_one html, 'form'
      end

      it "posts to #{Route::FILE_DUPLICATE}" do
        @form.must_be_form 'post', Route::FILE_DUPLICATE
      end

      it 'has a hidden input entry for original file name' do
        input = select_one @form, 'input[name="original"]'
        input.must_be_input type: 'hidden', value: @original_file_name
      end

      it 'has the original file name in the input box for new file name' do
        input = select_one @form, 'input[name="name"]'
        input.must_be_input type: 'text', value: @original_file_name
      end

      it 'has a create duplicate button' do
        input = select_one @form, 'input[type="submit"]'
        input.must_be_input type: 'submit', value: 'Create Duplicate'
      end
    end
  end

  #----------------------------------------------------------------------------

  describe with_id('must be logged in') do
    it 'has an error message' do
      get_file_duplicate('abc.txt', {}) { make_file @original_file_name }
      session.must_have_error :must_be_signed_in
    end
  end

  #----------------------------------------------------------------------------

  describe with_id('error handling') do
    @config = [
      {
        description: 'missing file name',
        file_name:   '',
        error:       :missing_file_name
      },
      {
        description: 'file does not exist',
        file_name:   TestHelpers::NO_SUCH_FILE,
        error:       :does_not_exist
      },
      {
        description: 'permission denied',
        file_name:   TestHelpers::SECRET_FILE,
        error:       :permission_denied
      }
    ].freeze

    before do
      File.chmod 0100, @secret_path
    end

    @config.each do |description:, file_name:, error:|
      describe with_id("handles '#{description}' errors") do
        before do
          get_file_duplicate file_name
        end

        it "redirects to #{Route::INDEX}" do
          must_redirect_to Route::INDEX
        end

        it 'has an error message' do
          session.must_have_error error
        end
      end
    end
  end
end
