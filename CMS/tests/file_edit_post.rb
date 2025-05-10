#!/usr/bin/env ruby
# Copyright (c) 2016 Pete Hanson
# frozen_string_literal: true

require_relative 'test_helpers'

#------------------------------------------------------------------------------

describe File.basename(__FILE__).to_s do
  include TestHelpers

  eval TestHelpers.setup_code # rubocop:disable Eval

  def post_file_edit file_name, session = admin_session
    @file_name = file_name
    @new_content = block_given? ? yield : ''
    post Route::FILE_EDIT, { name: @file_name, content: @new_content }, session
    get last_response.location
  end

  describe with_id('updating a file') do
    before do
      @content = 'Four score and seven years ago.'

      post_file_edit 'history.txt' do
        make_file @file_name, @content
        load_file(@file_name).reverse
      end
    end

    it 'has a completion message' do
      session.must_have_message :file_updated
    end

    it 'updates the file' do
      load_file(@file_name).must_equal @new_content
    end
  end

  #----------------------------------------------------------------------------

  describe with_id('must be logged in') do
    it 'has an error message' do
      post_file_edit('changes.txt', {}) { make_file @file_name }
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
        file_name:   TestHelpers::UNREADABLE_FILE,
        error:       :permission_denied
      }
    ].freeze

    before do
      make_file TestHelpers::UNREADABLE_FILE, mode: 0
    end

    @config.each do |description:, file_name:, error:|
      describe with_id("handles '#{description}' errors") do
        it 'has an error message' do
          post_file_edit(file_name) { 'this is new content' }
          session.must_have_error error
        end
      end
    end
  end
end
