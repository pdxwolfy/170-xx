#!/usr/bin/env ruby
# Copyright (c) 2016 Pete Hanson
# frozen_string_literal: true

require_relative 'test_helpers'

#------------------------------------------------------------------------------

describe File.basename(__FILE__).to_s do
  include TestHelpers

  setup = File.read((Pathname(__FILE__) + '..' + 'test_setup.rb').to_s)
  eval setup # rubocop:disable Eval

  def get_index *file_names
    @file_names = file_names
    @file_names.each { |file| yield file } if block_given?
    get Route::INDEX
  end

  describe with_id('displaying a file index') do
    before do
      file_names = %w(about.md changes.txt history.txt)
      get_index(*file_names) { |file| make_file file }
    end

    it 'shows an HTML page' do
      must_show_html Route::INDEX
    end

    it 'has view links for each file' do
      links = select_elements html, 'a.view', @file_names.size
      @file_names.zip links do |file_name, link|
        link.must_be_link "#{Route::FILE_VIEW}?name=#{file_name}", file_name
      end
    end

    it 'has edit links for each file' do
      links = select_elements html, 'a.edit', @file_names.size
      @file_names.zip links do |file_name, link|
        link.must_be_link "#{Route::FILE_EDIT}?name=#{file_name}", 'Edit'
      end
    end

    it 'has duplicate links for each file' do
      links = select_elements html, 'a.duplicate', @file_names.size
      @file_names.zip links do |file_name, link|
        route = "#{Route::FILE_DUPLICATE}?name=#{file_name}"
        link.must_be_link route, 'Duplicate'
      end
    end

    it 'has delete buttons for each file' do
      forms = select_elements html, 'form', @file_names.size
      @file_names.zip forms do |file_name, form|
        form.must_be_form 'post', Route::FILE_DELETE
        input = select_one form, 'input[name="name"]'
        input.must_be_input type: 'hidden', value: file_name
        button = select_one form, 'button'
        button.content.must_equal 'Delete'
      end
    end

    it 'has a new document link' do
      link = select_one html, 'a#new-document'
      link.must_be_link Route::FILE_NEW, 'New Document'
    end

    # tests for signin, signout, & signup buttons are in users_signout_post.rb
  end

  #----------------------------------------------------------------------------

  describe with_id('unreadable files are ignored') do
    before do
      remove_secret_path
      @unreadable_file = 'unreadable.txt'
      make_file @unreadable_file, mode: 0
      get_index('about.md') { |file| make_file file }
    end

    it 'shows an HTML page' do
      must_show_html Route::INDEX
    end

    it 'has only one view link, and it is for the readable file' do
      file_name = @file_names.first
      link = select_one html, 'a.view'
      link.must_be_link "#{Route::FILE_VIEW}?name=#{file_name}", file_name
    end

    it 'has only one edit link, and it is for the readable file' do
      file_name = @file_names.first
      link = select_one html, 'a.edit'
      link.must_be_link "#{Route::FILE_EDIT}?name=#{file_name}", 'Edit'
    end

    it 'has only one duplicate link, and it is for the readable file' do
      file_name = @file_names.first
      link = select_one html, 'a.duplicate'
      route = "#{Route::FILE_DUPLICATE}?name=#{file_name}"
      link.must_be_link route, 'Duplicate'
    end

    it 'has only one delete button, and it is for the readable file' do
      form = select_one html, 'form'
      form.must_be_form 'post', Route::FILE_DELETE
      input = select_one form, 'input[name="name"]'
      input.must_be_input type: 'hidden', value: @file_names.first
      button = select_one form, 'button'
      button.content.must_equal 'Delete'
    end
  end

  #----------------------------------------------------------------------------

  describe with_id('no readable files produces an empty list') do
    before do
      remove_secret_path
      get_index
    end

    it 'shows an HTML page' do
      must_show_html Route::INDEX
    end

    it 'has no file view links' do
      select_none html, 'a.view'
    end

    it 'has no edit links' do
      select_none html, 'a.edit'
    end

    it 'has no duplicae links' do
      select_none html, 'a.duplicate'
    end

    it 'has no delete buttons' do
      select_none html, 'form.delete'
    end

    it 'has a new document link' do
      link = select_one html, 'a#new-document'
      link.must_be_link Route::FILE_NEW, 'New Document'
    end
  end

  #----------------------------------------------------------------------------

  describe with_id('unknown extensions and subdirectories are ignored') do
    before do
      remove_secret_path
      make_dir 'xyz.txt'
      get_index('41', 'xyz.img') { |file| make_file file }
    end

    it 'has no view links' do
      select_none html, 'a.view'
    end
  end

  #----------------------------------------------------------------------------

  describe with_id('funky file names are encoded') do
    before do
      @encoded = 'Four%20score%20%3Cand%3E%20seven%25.txt'
      @escaped = 'Four score &lt;and&gt; seven%.txt'

      remove_secret_path
      get_index 'Four score <and> seven%.txt' do |file|
        make_file file, 'Just some text'
      end
    end

    it 'has encoded view link' do
      link = select_one html, 'a.view'
      route = "#{Route::FILE_VIEW}?name=#{@encoded}"
      link.must_be_link route, @file_names.first
    end

    it 'has escaped filename in link body' do
      # We need raw data here. Nokogiri does not provide it.
      link_pattern = %r{<a [^>]*class="view">(?<content>.*?)</a>}
      last_response.body.match(link_pattern)['content'].must_equal @escaped
    end

    it 'has encoded edit link' do
      link = select_one html, 'a.edit'
      link.must_be_link "#{Route::FILE_EDIT}?name=#{@encoded}", 'Edit'
    end

    it 'has encoded duplicate link' do
      link = select_one html, 'a.duplicate'
      link.must_be_link "#{Route::FILE_DUPLICATE}?name=#{@encoded}", 'Duplicate'
    end

    it 'has encoded delete button' do
      form = select_one html, 'form'
      input = select_one form, 'input[name="name"]'
      input.must_be_input type: 'hidden', value: @encoded
      button = select_one form, 'button'
      button.content.must_equal 'Delete'
    end
  end
end
