# frozen_string_literal: true

require 'set'
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

    @negative = Set.new
    @account_set = SortedSet.new
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
  def test_verify_user_input_true_filename
    assert_equal [true, 'sample.data'], verify_user_input(['sample.data'])
  end
  # 2. test that verify_user_input method return [false, nil] when not given any arguments
  def test_verify_user_input_false_nil
    assert_equal [false, nil], verify_user_input([])
  end
  # 3. test that verify_user_input method return [false, filename] when the given argument is not an existing file
  def test_verify_user_input_false_filename
    assert_equal [false, 'not_exist'], verify_user_input(['not_exist'])
  end
  

  # test read_file method
  # 1. test that read_file method read the given file and return the lines of the file in an array
  def test_read_file_success
    assert_equal ["1\n","2\n","3\n","4\n","5"], read_file('read_file_sample.data')
  end
  # 2. test that read_file method read empty file and return []
  def test_read_file_empty
    assert_equal [], read_file('empty.data')
  end


  # test valid_hash? method (need stub hash_str method)
  # 1. test that valid_hash? method return true and remain silence when the given blocks array is valid
  def test_valid_hash_true
    block_array = []
    File.open('sample.data').each do |line|
      block_array << line
    end
    assert valid_hash?(block_array, 0, 1)
    assert_output(""){valid_hash?(block_array, 0, 1)}
  end
  # 2. test that valid_hash? method return false and show error message when the given blocks has invalid data
  def test_valid_hash_false
    block_array = []
    File.open('read_file_sample.data').each do |line|
      block_array << line
    end
    refute valid_hash?(block_array, 0, 1)
    assert_output("Line 0: String '' hash set to 1, should be 0\nBLOCKCHAIN INVALID\n"){valid_hash?(block_array,0, 1)}
  end


  # test valid_blocks? method (need stub verify_line method)
  # 1. test that valid_blocks? method return false and show error message when any line is not valid
  def test_valid_blocks_false
    block_array = []
    File.open('read_file_sample.data').each do |line|
      block_array << line
    end
    refute valid_blocks?(block_array, 0)
    assert_output("Line 0: Cannot parse the block '1\n'\nBLOCKCHAIN INVALID\n"){valid_blocks?(block_array, 0)}
  end
  # 2. test that valid_blocks? method return true and remain silence when all lines are valid
  def test_valid_blocks_true
    block_array = []
    File.open('sample.data').each do |line|
      block_array << line
    end
    accounts = []
    assert valid_blocks?(block_array, accounts)
    assert_output(""){valid_blocks?(block_array, accounts)}
  end


  # test verify method (need to stub read_file, valid_hash?, valid_blocks?)
  # 1. test that if the given blockchain is valid, output the balance of all accounts
  def test_verify_valid
    assert_output("039873: 0 billcoins\n070668: 0 billcoins\n236340: 18 billcoins\n255185: 1 billcoins\n338967: 100 billcoins\n390411: 2 billcoins\n402207: 78 billcoins\n444100: 102 billcoins\n471345: 1 billcoins\n532260: 80 billcoins\n537882: 100 billcoins\n561180: 1 billcoins\n569274: 146 billcoins\n577469: 7 billcoins\n600381: 2 billcoins\n689881: 132 billcoins\n717802: 1 billcoins\n735567: 4 billcoins\n780971: 13 billcoins\n794343: 109 billcoins\n937639: 100 billcoins\n951990: 1 billcoins\n995917: 2 billcoins\n"){verify('sample.data')}
  end
  # 2. test that if the given blockchain is invalid, block by valid_blocks, print error message
  def test_verify_invalid
    assert_output("Line 1: Previous timestamp 1553184699.652449000 >= new timestamp 1553184699.650330000\nBLOCKCHAIN INVALID\n"){verify('invalid_sample.data')}
  end


  # test greater? method
  # 1. test that greater? return true if time1 > time2
  def test_greater_bigger
    time1 = '1553184699.652449000'
    time2 = '1553184699.650330000'
    assert greater?(time1, time2)
  end
  # 2. test that greater? return false if time1 == time2
  def test_greater_equal
    time1 = '1553184699.650330000'
    time2 = '1553184699.650330000'
    refute greater?(time1, time2)
  end
  # 3. test that greater? return false if time1 < time2
  def test_greater_smaller
    time1 = '1553184699.650330000'
    time2 = '1553184699.652449000'
    refute greater?(time1, time2)
  end
  # 4. test that greater? return false if time1 or time2 is not in valid form (optional)
  def test_greater_first_invalid
    time1 = '1553184699'
    time2 = '1553184699.650330000'
    refute greater?(time1, time2)
  end
  def test_greater_second_invalid
    time1 = '1553184699.650330000'
    time2 = '1553184699'
    refute greater?(time1, time2)
  end
  def test_greater_both_invalid
    time1 = '1553184699'
    time2 = '1553184699'
    refute greater?(time1, time2)
  end


  # test valid_transaction_pattern? method
  # 1. test that the method return true when given valid transaction with SYSTEM in front
  def test_valid_transaction_pattern_SYSTEM_in_front
    assert valid_transaction_pattern?('SYSTEM>532260(100)')
  end
  # 2. test that the method return true when given valid transaction without SYSTEM in front
  def test_valid_transaction_pattern_not_SYSTEM_front
    assert valid_transaction_pattern?('569274>735567(12)')
  end
  # 3. test that the method return false when given invalid transaction with SYSTEM in the second place
  def test_valid_transaction_pattern_SYSTEM_in_second
    refute valid_transaction_pattern?('569274>SYSTEM')
  end
  # 4. test that the method return false when the overall pattern is wrong
  def test_valid_transaction_pattern_all_wrong
    refute valid_transaction_pattern?('lalalalalala')
  end


  # test extract_info method
  # 1. test that the method return the correct value when given a valid input
  def test_extract_info_valid
    assert_equal ['402207', 794343, 10], extract_info('402207>794343(10)')
  end


  # test apply_transaction method (need stub extract_info)
  # 1. test that given a transaction with SYSTEM in front, the result is correct
  def test_apply_transaction_SYSTEM_front_result_correct
    accounts = []
    apply_transaction('SYSTEM>569274(100)', accounts, @negative)
    assert_equal 100, accounts[569274]
  end
  # 2. test that given a normal transaction without SYSTEM involved, the result is correct
  def test_apply_transaction_noSYSTEM_result_correct
    accounts = []
    apply_transaction('402207>794343(10)', accounts, @negative)
    assert_equal 10, accounts[794343]
  end
  # 3. test that given index that the value is 'nil', init it as 0 and calculate the result
  def test_apply_transaction_value_is_0
    accounts = []
    apply_transaction('402207>794343(10)', accounts, @negative)
    assert_equal 10, accounts[794343]
  end


  # test verify_transactions method (stub valid_transaction_pattern?, apply_transaction, @negative)
  # 1. test that if the given transactions string is empty, return false and print error message
  def test_verify_transactions_string_empty
    accounts = []
    refute verify_transactions('', accounts, 0)
    assert_output("Line 0: transaction list is empty\n"){verify_transactions('', accounts, 0)}
  end
  # 2. test that if any transaction has wrong pattern, return false and print error message
  def test_verify_transactions_pattern_wrong
    block_array = []
    invalid_transactions = 'abc'
    refute verify_transactions(invalid_transactions, block_array, 0)
    assert_output("Line 0: Cannot parse transaction 'abc'\n"){verify_transactions(invalid_transactions, block_array, 0)}
  end
  # 3. test that if any account is negative after the transactions, return false and print error message
  def test_verify_transactions_negative
    block_array = []
    negative_transactions = 'SYSTEM>569274(-100)'
    refute verify_transactions(negative_transactions, block_array, 0)
    assert_output("Line 0: transaction list is empty\n"){verify_transactions('', block_array, 0)}
  end
  # 4. test that if the input is valid, print nothing and return true
  def test_verify_transactions_all_valid
    accounts = []
    valid_transaction = 'SYSTEM>569274(100)'
    assert verify_transactions(valid_transaction, accounts, 0)
    assert_output(""){verify_transactions(valid_transaction, accounts, 0)}
  end

  # test show_error_message
  # 1. test the output of show_error_message is correct
  def test_show_error_message_correct
    assert_output("BLOCKCHAIN INVALID\n"){show_error_message}
  end

  # test show_usage
  # 1. test that the output of show_usage is correct
  def test_show_usage_correct
    assert_output("Usage: ruby verifier.rb <name_of_file>\n       name_of_file = name of file to verify\n"){show_usage}
  end


  # test verify_line (stub greater?, verify_transactions)
  # 1. test that report error when the pattern of the line is wrong
  def test_verify_line_pattern_wrong
    # let values.size != 5
    assert_output ("Line 1: Cannot parse the block '1'\n"){verify_line("1", 0, '288d', '1553184699.650330000', @account_set)}
  end
  # 2. test that report error when the line number is wrong
  def test_verify_line_lineNum_wrong
    # changed the 1 before the first '|' into 2
    assert_output ("Line 1: Invalid block number 2, should be 1\n"){verify_line("2|288d|569274>735567(12):735567>561180(3):735567>689881(2):SYSTEM>532260(100)|1553184699.652449000|92a2\n", 0, '288d', '1553184699.650330000', @account_set)}
  end
  # 3. test that report error when the hash is not consistant
  def test_verify_line_hash_notConsistant
    # changed the 288d before the second '|' into 292a
    assert_output ("Line 1: Previous hash was 292a, should be 288d\n"){verify_line("1|292a|569274>735567(12):735567>561180(3):735567>689881(2):SYSTEM>532260(100)|1553184699.652449000|92a2\n", 0, '288d', '1553184699.650330000', @account_set)}
  end
  # 4. test that report error when the timestamp is wrong
  def test_verify_line_timestamp_wrong
    # changed the time before the forth '|' into 1553184699.650330000
    assert_output ("Line 1: Previous timestamp 1553184699.650330000 >= new timestamp 1553184699.650330000\n"){verify_line("1|288d|569274>735567(12):735567>561180(3):735567>689881(2):SYSTEM>532260(100)|1553184699.650330000|92a2\n", 0, '288d', '1553184699.650330000', @account_set)}
  end  
  # 5. test that it return [false, nil, nil, nil] when the transactions are not valid
  def test_verify_line_transactions_invalid
    assert_equal [false, nil, nil, nil], verify_line("0|0|SYSTEM>569274(-100)|1553184699.650330000|288d\n", 0, '0', '0.0', @account_set)
  end
  # 6. test that it return [true, line_number, curr_hash, time] when the line is valid
  def test_verify_line_transactions_valid
    accounts = []
    verify_line("0|0|SYSTEM>569274(100)|1553184699.650330000|288d\n", -1, '0', '0.0', accounts)
    assert_equal [true, 1, '92a2', '1553184699.652449000'], verify_line("1|288d|569274>735567(12):735567>561180(3):735567>689881(2):SYSTEM>532260(100)|1553184699.652449000|92a2\n", 0, '288d', '1553184699.650330000', accounts)
#    assert_equal [true, 0, '288d', '1553184699.650330000'], verify_line("0|0|SYSTEM>569274(100)|1553184699.650330000|288d\n", 0, '0', '0.0', accounts)
  end
end
