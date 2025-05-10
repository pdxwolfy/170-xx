#!/usr/bin/env ruby
# Copyright (c) 2016 Pete Hanson
# frozen_string_literal: true

require_relative 'test_helpers'

#------------------------------------------------------------------------------

describe File.basename(__FILE__).to_s do
  include TestHelpers

  eval TestHelpers.setup_code # rubocop:disable Eval

  def get_file_view file_name
    @file_name = file_name
    yield if block_given?
    get Route::FILE_VIEW, name: @file_name
  end

  describe with_id('displaying a text file') do
    before do
      get_file_view 'changes.txt' do
        @content = "We the People\nof the United States"
        make_file @file_name, @content
      end
    end

    it 'shows an HTML page' do
      args = { type:  'text/plain', query: { name: @file_name } }
      must_show_html Route::FILE_VIEW, args
    end

    it 'contains content of file' do
      text.must_include @content
    end
  end

  #----------------------------------------------------------------------------

  describe with_id('displaying a markdown file') do
    before do
      get_file_view 'about.md' do
        make_file @file_name, "# The Gettysburg Address\n4 score and seven.\n"
      end

      @parsed_content = "<h1>The Gettysburg Address</h1>\n\n" \
                        "<p>4 score and seven.</p>\n"
    end

    it 'shows an HTML page' do
      must_show_html Route::FILE_VIEW, query: { name: @file_name }
    end

    it 'contains content of file' do
      last_response.body.must_include @parsed_content # Don't use Nokogiri here
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
      make_file TestHelpers::UNREADABLE_FILE, mode: 0
      File.chmod 0100, @secret_path
    end

    @config.each do |description:, file_name:, error:|
      describe with_id("handles '#{description}' errors") do
        before do
          get_file_view file_name
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
