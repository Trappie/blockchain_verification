# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'utils'

# testing class for utils.rb
class UtilsTest < Minitest::Test
  def setup
    # encoding_array global for hash_str
    @encoding_array = []
    @encoding_array[48] = 45_503
    @encoding_array[49] = 55_689
    @encoding_array[50] = 12_807
    @encoding_array[51] = 57_191
    @encoding_array[52] = 11_791
    @encoding_array[53] = 48_421
    @encoding_array[54] = 22_487
    @encoding_array[55] = 54_491
    @encoding_array[56] = 20_831
    @encoding_array[57] = 19_809
    @encoding_array[97] = 6425
    @encoding_array[98] = 54_727
    @encoding_array[99] = 40_407
    @encoding_array[40] = 28_191
    @encoding_array[41] = 62_257
    @encoding_array[46] = 27_447
    @encoding_array[62] = 119
    @encoding_array[83] = 15_623
    @encoding_array[89] = 27_585
    @encoding_array[84] = 52_367
    @encoding_array[69] = 8789
    @encoding_array[77] = 10_669
    @encoding_array[58] = 11_431
    @encoding_array[100] = 17_359
    @encoding_array[101] = 2741
    @encoding_array[102] = 53_143
    @encoding_array[124] = 51_375
  end

  # test the hash_str function
  # 1. test that the hash function work correctly when given a valid first line
  def test_hash_str_first_line
    str_to_hash = '0|0|SYSTEM>569274(100)|1553184699.650330000'
    assert_equal '288d', hash_str(str_to_hash, @encoding_array)
  end

  # 2. test that the hash function work correctly on a given line in the middle of the blockchain
  def test_hash_str_other_line
    str_to_hash = '1|288d|569274>735567(12):735567>561180(3):735567>689881(2):SYSTEM>532260(100)|1553184699.652449000'
    assert_equal '92a2', hash_str(str_to_hash, @encoding_array)
  end

  # test verify_user_input method
  # 1. test that verify_user_input method return [true, filename] when given a valid filename
  # 2. test that verify_user_input method return [false, nil] when not given any arguments
  # 3. test that verify_user_input method return [false, filename] when the given argument is not an existing file

  # test read_file method
  # 1. test that read_file method read the given file and return the lines of the file in an array
  # 2. test that read_file method read empty file and return []

  # test valid_hash? method (need stub hash_str method)
  # 1. test that valid_hash? method return true and remain silence when the given blocks array is valid
  # 2. test that valid_hash? method return false and show error message when the given blocks has invalid data

  # test valid_blocks? method (need stub verify_line method)
  # 1. test that valid_blocks? method return false and show error message when any line is not valid
  # 2. test that valid_blocks? method return true and remain silence when all lines are valid

  # test verify method (need to stub read_file, valid_hash?, valid_blocks?)
  # 1. test that if the given blockchain is valid, output the balance of all accounts
  # 2. test that if the given blockchain is invalid, output nothing

  # test greater? method
  # 1. test that greater? return true if time1 > time2
  # 2. test that greater? return false if time1 == time2
  # 3. test that greater? return false if time1 < time2
  # 4. test that greater? return false if time1 or time2 is not in valid form (optional)

  # test valid_transaction_pattern? method
  # 1. test that the method return true when given valid transaction with SYSTEM in front
  # 2. test that the method return true when given valid transaction without SYSTEM in front
  # 3. test that the method return false when given invalid transaction with SYSTEM in the second place
  # 4. test that the method return false when the overall pattern is wrong

  # test extract_info method
  # 1. test that the method return the correct value when given a valid input

  # test apply_transaction method (need stub extract_info)
  # 1. test that given a transactio with SYSTEM in front, the result is correct
  # 2. test that given a normal transaction without SYSTEM involved, the result is correct
  # 3. test that after the transaction, if the first account's balance become negative, it will be in the negative_set
  # 4. test that after the transaction, if the second account's balance is positive, it will be moved out of negative_set
  # 5. test that given index that the value is 'nil', init it as 0 and calculate the result

  # test verify_transactions method (stub valid_transaction_pattern?, apply_transaction, @negative)
  # 1. test that if the given transactions string is empty, return false and print error message
  # 2. test that if any transaction has wrong pattern, return false and print error message
  # 3. test that if all transactions are in valid pattern, the apply_transaction method will be called n times(n transaction)
  # 4. test that if any account is negative after the transactions, return false and print error message
  # 5. test that if the input is valid, print nothing and return true

  # test show_error_message
  # 1. test the output of show_error_message is correct

  # test show_usage
  # 1. test that the output of show_usage is correct

  # test verify_line (stub greater?, verify_transactions)
  # 1. test that report error when the pattern of the line is wrong
  # 2. test that report error when the line number is wrong
  # 3. test that report error when the hash is not consistant
  # 4. test that report error when the timestamp is wrong
  # 5. test that it return [false, nil, nil, nil] when the transactions are not valid
  # 6. test that it return [true, line_number, curr_hash, time] when the line is valid
end
