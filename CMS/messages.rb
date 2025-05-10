#!/usr/bin/env ruby
# Copyright (c) 2016 Pete Hanson
# frozen_string_literal: true

# Message storage structure with automatic substitution
class Messages
  module Messages
    # :nocov:
    TEST_MESSAGES =
      if testing?
        { signed_in_as: 'Signed in as %<@username>s' }
      else
        {}
      end
    # :nocov:

    TEST_MESSAGES.freeze

    MESSAGES = {
      account_created:     'Account created. Please signin.',
      could_not_create:    '%<@file_name>s: File creation failed.',
      created_file:        '%{@file_name}: File created..',
      does_not_exist:      '%<@file_name>s: File does not exist.',
      duplicate_created:   '%{@file_name}: Duplicate of ' \
                           '%{@original_file_name} created.',
      enter_file_name:     'Please enter a file name.',
      file_deleted:        '%<@file_name>s: File was deleted.',
      file_exists:         '%<@file_name>s: File already exists.',
      file_updated:        '%{@file_name} was updated.',
      invalid_credentials: 'Invalid Credentials',
      missing_file_name:   'Missing file name',
      missing_password:    'Please enter your desired password.',
      missing_username:    'Please enter your desired username.',
      must_be_signed_in:   'You must be signed in to do that.',
      password_too_short:  'Your password must be at least 8 characters long.',
      permission_denied:   '%<@file_name>s: Permission denied.',
      signed_out:          'You have been signed out.',
      unknown_file_type:   'Unknown file extension.',
      username_in_use:     'That user name is already taken. Sorry.',
      welcome:             'Welcome!'
    }.merge!(TEST_MESSAGES).freeze
  end.freeze

  def initialize app
    @app = app
    @unwanted_instance_variables = @app.instance_variables
  end

  def [] id
    fetch id
  end

  # :reek:FeatureEnvy
  def fetch id, **other_variables
    Messages::MESSAGES[id] % instance_variable_lookup_table(other_variables)
  end

  def fetch_all ids, **other_variables
    ids.map { |id| fetch id, other_variables }
  end

  private

  def app_instance_variables
    variables = @app.instance_variables - @unwanted_instance_variables
    variables.map do |name|
      value = @app.instance_variable_get name
      [name, value]
    end
  end

  def instance_variable_lookup_table other_variables
    names_and_values = app_instance_variables
    Hash[names_and_values].merge Hash[parse other_variables]
  end

  def parse other_variables
    other_variables.map { |id, value| ["@#{id}".to_sym, value] }
  end
end
