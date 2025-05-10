#!/usr/bin/env ruby
# Copyright (c) 2016 Pete Hanson
# frozen_string_literal: true

unless ENV['RACK_ENV'] == 'test'
  ENV['RACK_ENV'] = 'test'
  require 'simplecov'
  SimpleCov.minimum_coverage 100 if $PROGRAM_NAME =~ %r{/tests/cms\.rb}
  SimpleCov.start
end

require 'awesome_print'
require 'minitest/assertions'
require 'minitest/autorun'
require 'minitest/reporters'
require 'nokogiri'
require 'pry'
require 'rack/test'

require_relative '../cms'
require_relative '../messages'

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

#------------------------------------------------------------------------------

# Complex expectations that don't belong in Minitest::Expectations
# For some reason, last_{request,response} don't inherit custom expectations
module Expectations
  HTML_UTF8 = 'text/html;charset=utf-8'

  def must_redirect_to expected_route
    check_response expected_route, :redirect?
    follow_redirect!
    check_response expected_route, :ok?
  end

  def must_show_html expected_route, option_hash = {}
    last_request.path_info.must_equal     expected_route
    query_hash.must_equal                 option_hash[:query]  || {}
    last_response.must_be                 option_hash[:status] || :ok?
    last_response.content_type.must_equal option_hash[:type]   || HTML_UTF8
  end

  private

  def check_response expected_route, expected_status_predicate
    last_response.must_be expected_status_predicate
    localpath.must_equal expected_route
  end

  def localpath
    location.sub %r{\Ahttp://example\.org\b}, ''
  end
end

#------------------------------------------------------------------------------

# Custom assertions
module Minitest::Assertions
  def assert_button_tag button, content = nil, **attributes
    assert_tag button, 'button', content, **attributes
  end

  def assert_error actual_session, expected_error_id, **expected_params
    errors = flash actual_session, :error
    expected = @message.fetch expected_error_id, expected_params
    assert_includes errors, expected
  end

  # :reek:LongParameterList
  def assert_form_tag form, method, action, **attributes
    assert_tag form, 'form', **attributes, method: method, action: action
  end

  def assert_input_tag input, **attributes
    assert_tag input, 'input', **attributes
  end

  # :reek:LongParameterList
  def assert_link_tag link, expected_href, expected_content = nil, **attributes
    assert_tag link, 'a', expected_content, **attributes, href: expected_href
  end

  def assert_message actual_session, expected_message_id, **expected_params
    messages = flash actual_session, :message
    expected = @message.fetch expected_message_id, expected_params
    assert_includes messages, expected
  end

  # :reek:LongParameterList
  def assert_tag tag, expected_name, expected_content = nil,
                 **expected_attributes
    assert_equal expected_name, tag.name
    expected_attributes.each_pair do |attribute, value|
      assert_equal value, tag.attr(attribute)
    end

    assert_equal expected_content.strip, tag.content.strip if expected_content
  end

  # :reek:LongParameterList
  def assert_textarea_tag textarea, expected_content, **attributes
    assert_tag textarea, 'textarea', expected_content, **attributes
  end

  def refute_error actual_session
    errors = flash actual_session, :error
    assert_empty errors
  end

  def refute_message actual_session
    messages = flash actual_session, :message
    assert_empty messages
  end

  private

  def flash actual_session, type
    messages = actual_session[type]
    if messages
      return messages if messages.respond_to? :each
      return [messages]
    end

    flash_block = html.css ".flash.#{type}"
    return [] if flash_block.empty?
    text flash_block.first
  end
end

#------------------------------------------------------------------------------

# Custom expectations
module Minitest::Expectations
  infections = {
    assert_button_tag:   %i(must_be_button    many),
    assert_error:        %i(must_have_error   reversed),
    assert_form_tag:     %i(must_be_form      many),
    assert_input_tag:    %i(must_be_input     many),
    assert_link_tag:     %i(must_be_link      many),
    assert_message:      %i(must_have_message reversed),
    assert_tag:          %i(must_be_tag       many),
    assert_textarea_tag: %i(must_be_textarea  many),
    refute_error:        %i(wont_have_error   unary),
    refute_message:      %i(wont_have_message unar)
  }

  infections.each_pair do |assertion, expectation|
    Enumerable.infect_an_assertion assertion, *expectation
  end

  Enumerable.infect_an_assertion :assert_redirect_to, :must_redirect_to
end

#------------------------------------------------------------------------------

# Helpers for access to HTML of a page
module HTMLHelpers
  def html
    Nokogiri::HTML last_response.body
  end

  # :reek:UtilityFunction
  def select_elements source, selector, count = nil
    elements = source.css selector
    if count
      elements.size.must_equal count, "Expected #{elements.inspect}\n" \
                                      "to have exactly #{count} element(s)."
    end

    elements
  end

  def select_none *args
    select_elements(*args, 0)
  end

  def select_one *args
    elements = select_elements(*args, 1)
    elements.first
  end

  def session
    last_request.env['rack.session']
  end

  # Returns array of all text nodes in a node that have at least one non-
  # whitespace character
  def text node = html.css('body').first
    node.search('.//text()').map(&:text).map(&:strip).reject(&:empty?)
  end

  private

  def location
    last_response.location || last_request.fullpath
  end

  def query_hash
    query_values = last_request.query_string.split('&').map do |name_eq_value|
      name, value = name_eq_value.split '='
      [name.to_sym, value || '']
    end

    Hash[query_values]
  end
end

#------------------------------------------------------------------------------

# Helpers for working with files and paths
module FilePathHelpers
  SECRET_DIR        = 'super-secret'
  SECRET_NAME       = 'secret.txt'
  SECRET_FILE       = File.join SECRET_DIR, SECRET_NAME
  NO_SUCH_DIRECTORY = 'invalid/name.txt'
  NO_SUCH_FILE      = 'no-such-file.txt'
  UNREADABLE_FILE   = 'unreadable-file.txt'
  UNWRITABLE_FILE   = 'unwritable-file.txt'

  # :reek:FeatureEnvy
  def create_auth_file
    File.open auth_file, 'w' do |file|
      TestHelpers.credentials.each do |userinfo|
        file.puts "#{userinfo.username}: #{userinfo.encrypted_password}"
      end
    end
  end

  def create_auth_path
    FileUtils.mkdir_p auth_path
  end

  def create_data_path
    FileUtils.mkdir_p data_path
  end

  def create_secret_path
    make_dir SECRET_DIR, 0700

    @secret_path = path_name SECRET_DIR
    @secret_file = SECRET_FILE
    make_file @secret_file, 'This is top secret'
    File.chmod 0, File.join(@secret_path, SECRET_NAME), @secret_path
  end

  def exist? file_name
    File.exist? path_name(file_name)
  end

  def load_file file_name
    File.read path_name(file_name)
  end

  def make_dir name, mode = 0755
    path = path_name name
    Dir.mkdir path, mode
  end

  def make_file name, content = '', **config
    save_file name, content, **config
  end

  def remove_auth_path
    path = auth_path
    FileUtils.rm_rf path if path
  end

  def remove_data_path
    path = data_path
    FileUtils.rm_rf path if path
  end

  def remove_secret_path
    return unless @secret_path

    File.chmod 0755, @secret_path, File.join(@secret_path, SECRET_NAME)
    FileUtils.rm_rf @secret_path
    @secret_path = nil
  end

  def save_file file_name, content, **config
    path = path_name file_name
    mode = config[:mode]

    File.write path, content
    File.chmod mode, path if mode
  end

  private

  def path_name file_name
    File.join data_path, file_name
  end
end

#------------------------------------------------------------------------------

# Helpers for the variaus unit tests
module TestHelpers
  include Rack::Test::Methods
  include Minitest::Assertions
  include Minitest::Expectations
  include Expectations
  include FilePathHelpers
  include HTMLHelpers

  # User credentials
  UserInfo = Struct.new :username, :raw_password do
    def encrypted_password
      @encrypted_password ||= BCrypt::Password.create raw_password
    end
  end

  def self.credentials
    return @credentials if @credentials

    @credentials = []
    admin = UserInfo.new TestMode::Admin::USERNAME, TestMode::Admin::PASSWORD
    @credentials <<
      admin <<
      UserInfo.new('wolfy', 'me-and-my-shadow') <<
      UserInfo.new('pete', 'you-and-your-shadow')
  end

  def self.setup_code
    setup_file = Pathname(__FILE__) + '..' + 'test_setup.rb'
    File.read setup_file.to_s
  end

  def admin_session
    { 'rack.session' => { username: TestMode::Admin::USERNAME } }
  end

  def app
    Sinatra::Application
  end

  def self.suite_id
    @ident ||=
      Enumerator.new do |yielder|
        ident = 0
        loop do
          ident += 10
          yielder.yield format('%04d', ident)
        end
      end

    @ident.next
  end
end

# :reek:UtilityFunction
def with_id text
  "#{TestHelpers.suite_id} #{text}"
end
