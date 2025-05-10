#!/usr/bin/env ruby
# Copyright (c) 2016 Pete Hanson
# frozen_string_literal: true

require_relative 'test_helpers'

#------------------------------------------------------------------------------

describe File.basename(__FILE__).to_s do
  include TestHelpers

  eval TestHelpers.setup_code # rubocop:disable Eval

  def post_file_duplicate original_file, dup_file, session = admin_session
    @original_file_name = original_file
    @file_name = dup_file
    @content = "Four score and seven.\n"
    yield if block_given?
    env = { name: @file_name, original: @original_file_name }
    post Route::FILE_DUPLICATE, env, session
  end

  describe with_id('file duplication works') do
    before do
      post_file_duplicate 'about.txt', 'duplicate.txt' do
        make_file @original_file_name, @content
        @path_name = File.join data_path, @file_name
      end
    end

    it 'has a completion message' do
      variables = { original_file_name: @original_file_name }
      session.must_have_message :duplicate_created, variables
    end

    it 'creates the new file' do
      File.file?(@path_name).must_equal true
    end

    it 'creates a readable file' do
      File.readable?(@path_name).must_equal true
    end

    it 'creates duplicate of original file' do
      File.read(@path_name).must_equal @content
    end
  end

  #----------------------------------------------------------------------------

  describe with_id('must be logged in') do
    it 'has an error message' do
      post_file_duplicate 'changes.txt', 'duplicate.txt', {}
      session.must_have_error :must_be_signed_in
    end
  end

  #--------------------------------------------------------------------------

  describe with_id('handles file name collision error') do
    before do
      post_file_duplicate 'about.txt', 'duplicate.txt' do
        @content = 'Four score'
        make_file @original_file_name, @content
        make_file @file_name
      end
    end

    it 'shows an HTML page' do
      must_show_html Route::FILE_DUPLICATE
    end

    it 'has an error message' do
      session.must_have_error :file_exists
    end

    it 'has the user-entered name still in the text box' do
      input = select_one html, 'input[name="name"]'
      input.must_be_input type: 'text', value: @file_name
    end

    it 'does not modify the original file' do
      load_file(@original_file_name).must_equal @content
    end
  end

  #----------------------------------------------------------------------------

  describe with_id('error handling for source file') do
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
        before do
          File.chmod 0100, @secret_path
          post_file_duplicate file_name, 'duplicate.txt'
        end

        it 'shows an HTML page' do
          must_show_html Route::FILE_DUPLICATE
        end

        it 'has an error message' do
          session.must_have_error error, file_name: @original_file_name
        end

        it 'has a hidden input entry for original file name' do
          input = select_one html, 'input[name="original"]'
          input.must_be_input type: 'hidden', value: @original_file_name
        end

        it 'has the new file name in the input box' do
          input = select_one html, 'input[name="name"]'
          input.must_be_input type: 'text', value: @file_name
        end
      end
    end
  end

  #----------------------------------------------------------------------------

  describe with_id('error handling for target file') do
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
          post_file_duplicate 'about.txt', file_name do
            make_file @original_file_name, @content
          end
        end

        it 'shows an HTML page' do
          must_show_html Route::FILE_DUPLICATE
        end

        it 'has an error message' do
          session.must_have_error error
        end

        it 'has a hidden input entry for original file name' do
          input = select_one html, 'input[name="original"]'
          input.must_be_input type: 'hidden', value: @original_file_name
        end

        it 'has the new file name in the input box' do
          input = select_one html, 'input[name="name"]'
          input.must_be_input type: 'text', value: @file_name
        end
      end
    end
  end

  #----------------------------------------------------------------------------

  #     end
  #   end
  # end
end
