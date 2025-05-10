#!/usr/bin/env ruby
# Copyright (c) 2016 Pete Hanson
# frozen_string_literal: true

require_relative 'test_helpers'

#------------------------------------------------------------------------------

describe File.basename(__FILE__).to_s do
  include TestHelpers

  eval TestHelpers.setup_code # rubocop:disable Eval

  def post_file_delete file_name, session = admin_session
    @file_name = file_name
    post Route::FILE_DELETE, { name: @file_name }, session
  end

  describe with_id('deleting a file') do
    before do
      @file_name_delete = 'delete.txt'
      @file_name_keep = 'history.txt'
      [@file_name_delete, @file_name_keep].each { |name| make_file name }

      post_file_delete @file_name_delete
    end

    it 'has a deletion message' do
      session.must_have_message :file_deleted
    end

    it 'deletes the file' do
      exist?(@file_name_delete).must_equal false
    end

    it 'does not delete other files' do
      exist?(@file_name_keep).must_equal true
    end
  end

  #----------------------------------------------------------------------------

  describe with_id('must be logged in') do
    it 'has an error message' do
      post_file_delete('delete.txt', {}) { |name| make_file name }
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

    @config.each do |description:, file_name:, error:|
      describe with_id("handles '#{description}' errors") do
        it 'has an error message' do
          File.chmod 0500, @secret_path
          post_file_delete file_name
          session.must_have_error error
        end
      end
    end
  end
end
