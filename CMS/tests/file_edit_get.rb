#!/usr/bin/env ruby
# Copyright (c) 2016 Pete Hanson
# frozen_string_literal: true

require_relative 'test_helpers'

#------------------------------------------------------------------------------

describe File.basename(__FILE__).to_s do
  include TestHelpers

  eval TestHelpers.setup_code # rubocop:disable Eval

  def get_file_edit file_name, session = admin_session
    @file_name = file_name
    yield if block_given?
    get Route::FILE_EDIT, { name: @file_name }, session
  end

  describe with_id('the basic file edit page') do
    before do
      @content = <<-END.sub(/^\s+/, '')
        This is the content of the file.
        Presumably, you want to edit it.
      END
      get_file_edit('changes.txt') { make_file @file_name, @content }
    end

    it 'shows an HTML page' do
      must_show_html Route::FILE_EDIT, query: { name: @file_name }
    end

    it 'tells user to edit the content' do
      text.must_include 'Edit content of changes.txt:'
    end

    describe with_id('the file editing form') do
      before do
        @form = select_one html, 'form'
      end

      it "posts to #{Route::FILE_EDIT}" do
        @form.must_be_form 'post', Route::FILE_EDIT
      end

      it 'has a hidden input for file name' do
        input = select_one @form, 'input[name="name"]'
        input.must_be_input type: 'hidden', value: @file_name
      end

      it 'has a textarea for the file content' do
        textarea = select_one @form, 'textarea[name="content"]'
        textarea.must_be_textarea @content
      end
    end
  end

  #----------------------------------------------------------------------------

  describe with_id('must be logged in') do
    it 'has an error message' do
      get_file_edit('changes.txt', {}) { make_file @file_name }
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
        before do
          get_file_edit file_name
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
