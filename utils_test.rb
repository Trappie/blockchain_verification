# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'utils'

# testing class for utils.rb
class UtilsTest < Minitest::Test
  # test that the hash function work correctly
  def test_hash_str
    str_to_hash = 'bill'
    assert_equal 'f896', hash_str(str_to_hash)
  end

  # test verify_user_input method

  # test that the verify_user_input method return [false, nil] when given no arguments
  def test_verify_user_input_no_args
    assert_equal [false, nil], verify_user_input([])
  end

  # test that the verify_user_input method return [false, nil] when given file name that doesn't exist
  def test_verify_user_input_file_not_exist
    assert_equal [false, 'not_exist'], verify_user_input(['not_exist'])
  end

  # test that the verify_user_input method return [true, filename] when given existed file
  def test_verify_user_input_exist
    assert_equal [true, 'verifier.rb'], verify_user_input(['verifier.rb'])
  end
end
