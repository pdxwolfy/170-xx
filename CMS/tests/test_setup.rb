#!/usr/bin/env ruby
# Copyright (c) 2016 Pete Hanson
# frozen_string_literal: true

make_my_diffs_pretty!

before do
  @message = Messages.new self

  remove_data_path
  create_data_path

  remove_secret_path
  create_secret_path

  remove_auth_path
  create_auth_path
  create_auth_file
end

after do
  remove_secret_path
  remove_data_path
  remove_auth_path
end
