#!/usr/bin/env ruby
# Copyright (c) 2016 Pete Hanson
# frozen_string_literal: true

require_relative 'test_helpers'

#------------------------------------------------------------------------------

describe File.basename(__FILE__).to_s do
  include TestHelpers

  eval TestHelpers.setup_code # rubocop:disable Eval

  def post_file_new file_name, session = admin_session
    @file_name = file_name
    yield if block_given?
    post Route::FILE_NEW, { name: @file_name }, session
  end

  describe with_id('file creation works') do
    it 'has a completion message' do
      post_file_new 'a-new-file.txt'
      session.must_have_message :created_file
    end
  end

  #----------------------------------------------------------------------------

  describe with_id('must be logged in') do
    it 'has an error message' do
      post_file_new 'changes.txt', {}
      session.must_have_error :must_be_signed_in
    end
  end

  #--------------------------------------------------------------------------

  describe with_id('handles file name collision error') do
    before do
      post_file_new 'an-existing-file.txt' do
        @content = 'Four score'
        make_file @file_name, @content
      end
    end

    it 'shows an HTML page' do
      must_show_html Route::FILE_NEW
    end

    it 'has an error message' do
      session.must_have_error :file_exists
    end

    it 'has the user-entered name still in the text box' do
      input = select_one html, 'input[name="name"]'
      input.must_be_input type: 'text', value: @file_name
    end

    it 'does not modify the original file' do
      load_file(@file_name).must_equal @content
    end
  end

  #----------------------------------------------------------------------------

  describe with_id('error handling') do
    @config = [
      {
        description: 'missing file name',
        file_name:   '',
        error:       :enter_file_name
      },
      {
        description: 'missing directory',
        file_name:   TestHelpers::NO_SUCH_DIRECTORY,
        error:       :could_not_create
      },
      {
        description: 'permission denied',
        file_name:   TestHelpers::SECRET_FILE,
        error:       :permission_denied
      }
    ].freeze

    @config.each do |description:, file_name:, error:|
      describe with_id("handles '#{description}' errors") do
        before do
          post_file_new file_name
        end

        it 'shows an HTML page' do
          must_show_html Route::FILE_NEW
        end

        it 'has an error message' do
          session.must_have_error error
        end

        it 'has the original file name in the input box' do
          input = select_one html, 'input[name="name"]'
          input.must_be_input type: 'text', value: file_name
        end
      end
    end
  end
end
