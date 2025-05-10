#!/usr/bin/env ruby
# Copyright (c) 2016 Pete Hanson
# frozen_string_literal: true

require_relative 'test_helpers'

#------------------------------------------------------------------------------

describe File.basename(__FILE__).to_s do
  include TestHelpers

  setup = File.read((Pathname(__FILE__) + '..' + 'test_setup.rb').to_s)
  eval setup # rubocop:disable Eval

  #----------------------------------------------------------------------------

  describe with_id('page layout') do
    before do
      get TestMode::Route::LAYOUT
    end

    it 'is intentionally blank' do
      main_text = select_one html, 'main'
      main_text_list = text main_text
      main_text_list.size.must_equal 1
      main_text_list.first.must_equal TestMode::EMPTY_PAGE
    end
  end

  #----------------------------------------------------------------------------

  describe with_id('error messages are handled appropriately') do
    before do
      @error_id = :enter_file_name
      session_values error: @message[@error_id]
      get TestMode::Route::LAYOUT
    end

    it 'has an error message' do
      session.must_have_error @error_id
    end

    it 'does not have an informational message' do
      session.wont_have_message
    end

    it 'hides error message after reload' do
      get TestMode::Route::LAYOUT
      session.wont_have_error
    end
  end

  #----------------------------------------------------------------------------

  describe with_id('informational messages are handled appropriately') do
    before do
      @message_id = :welcome
      session_values message: @message[@message_id]
      get TestMode::Route::LAYOUT
    end

    it 'has an informational message' do
      session.must_have_message @message_id
    end

    it 'does not have an error message' do
      session.wont_have_error
    end

    it 'hides informational message after reload' do
      get TestMode::Route::LAYOUT
      session.wont_have_message
    end
  end

  #----------------------------------------------------------------------------

  describe with_id('both errors and informational messages work when combined') do
    before do
      @error_id = :unknown_file_type
      @message_id = :welcome
      session_values message: @message[@message_id], error: @message[@error_id]
      get TestMode::Route::LAYOUT
    end

    it 'has an informational message' do
      session.must_have_message @message_id
    end

    it 'has an error message' do
      session.must_have_error @error_id
    end

    it 'hides both messages after reload' do
      get TestMode::Route::LAYOUT
      session.wont_have_message
      session.wont_have_error
    end
  end
end
