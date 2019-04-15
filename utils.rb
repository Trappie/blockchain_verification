# frozen_string_literal: true

require 'set'
require 'English'

# global variable represent the accounts with negative balance
# should be empty after processing each block
@negative = Set.new
# the sorted set to keep all accounts show up in the blockchain, it's used for final output
@account_set = SortedSet.new
# the encoding array with pre-calculated hash value
# for example, the UTF-8 encoding of '0' is 48 (base 10)
# so the @encoding_array[48] = 45503, which is (((48**3000) + (48**48) - (3**48)) * (7**48)) % 65536
# because the characters used in the hashing is limited, so it's faster to retrieve instead of calculate in runtime
# also I use array instead of a hashmap because array is faster (in my case, 100ms) than hashmap
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

# given a message of text string in form of utf-8, return the hashed value
# example:
# given 'bill'
# should return 'f896'
def hash_str(message, encoding_array)
  encodings = message.unpack('U*') # get the encoding of every character
  sum = encodings.reduce(0) { |tmp_sum, encoding| tmp_sum + encoding_array[encoding] } # add the hash value of chars
  (sum % 65_536).to_s(16) # modular and output as hexidecimal
end

# verify the arguments passed in when running the program
# examples:
# args = [] no arguments
# return [false, nil]
# args = ['not_exist']
# return [false, 'not_exist'], the file name is returned in this case
# args = ['exist.txt']
# return [true, 'exist.txt']
def verify_user_input(args)
  if args.empty?
    [false, nil]
  elsif File.file?(args[0])
    [true, args[0]]
  else
    [false, args[0]]
  end
end

# read the given file and return the array contains each line
def read_file(filename)
  rtn = []
  File.open(filename).each do |line|
    rtn << line
  end
  rtn
end

# verify the hash of the given array of blocks
# print error message if any hash is wrong
# the range to check is in [start_index, end_index)
def valid_hash?(blocks, start_index, end_index)
  index = start_index
  loop do
    break if index >= end_index

    # verify the index-th line here
    strings = blocks[index].split('|')
    str = strings[0...-1].join('|')
    hash_code = strings[-1][0...-1]
    calc_hash = hash_str(str, @encoding_array)
    unless calc_hash == hash_code
      puts "Line #{index}: String '#{str}' hash set to #{hash_code}, should be #{calc_hash}"
      show_error_message
      return false
    end
    index += 1
  end
  true
end

# verify the information of the blocks, exclude the hash part
# print error message when something goes wrong
def valid_blocks?(blocks, accounts)
  prev_line_number = -1
  prev_time = '0.0'
  prev_hash = '0'

  blocks.each do |line|
    valid, prev_line_number, prev_hash, prev_time = verify_line(line, prev_line_number, prev_hash, prev_time, accounts)
    unless valid
      show_error_message
      return false
    end
  end
  true
end

# verify the given blockchain file and print out the result
def verify(filename)
  block_array = read_file(filename)
  accounts = []

  # fork a new process to verify the hash of the whole array
  hashing = fork do
    if valid_hash?(block_array, 0, block_array.length)
      exit(1)
    else
      exit(0)
    end
  end

  # check the parts other than hash of the blockchain
  if valid_blocks?(block_array, accounts) # if the block information is correct
    Process.wait # wait for the hash part to return
    code = $CHILD_STATUS.exitstatus # get the exit code of the hash verifying process
    if code == 1 # the hash of the file is valid, so the blockchain is totally valid
      @account_set.each do |index|
        puts "#{index.to_s.rjust(6, '0')}: #{accounts[index]} billcoins" # show the result with proper format
      end
    end
  else # if blocks is not valid
    Process.kill('HUP', hashing) # kill the hash verifying process to terminate the whole thing
  end
end

# check whether time1 is greater than time2
# if time1 is 1553184699.685386000
# and time2 is 1553184699.685386001
# then the method should return false
def greater?(time1, time2)
  v1 = time1.split('.')
  v2 = time2.split('.')
  return false unless v1.size == 2 && v2.size == 2

  main_value1 = v1[0]
  main_value2 = v2[0]
  return v1[1].to_i > v2[1].to_i if main_value1 == main_value2

  main_value1 > main_value2
end

# check that the given trans str is in the correct patter of transaction record
# return false is the given string is not in the patter 'xxxxxx>xxxxxx(xxx)'
# in which x is normally some digits and the first xxxxxx could be SYSTEM
def valid_transaction_pattern?(trans_str)
  /^[0-9]{6}>[0-9]{6}\([0-9]+\)$/.match?(trans_str) || /^SYSTEM>[0-9]{6}\([0-9]+\)$/.match?(trans_str)
end

# extract information from the given transaction
# example, if given '402207>794343(10)'
# the return valud will be ['402207', 794343, 10], notice that the first item is a string
def extract_info(transaction)
  [transaction[0...6], transaction[7...13].to_i, transaction[14...-1].to_i]
end

# apply a single transaction to accounts
# if some transaction make an account's balance to be negative, save it in the negative_set
# if some transaction make an account's balance become from negative to be positive, remove it from negative_set
def apply_transaction(transaction, accounts, negative_set)
  a1, a2, amount = extract_info(transaction)
  if a1 != 'SYSTEM'
    a1 = a1.to_i
    accounts[a1] = 0 if accounts[a1].nil?
    accounts[a1] -= amount
    negative_set.add(a1) if accounts[a1].negative?
  end
  accounts[a2] = 0 if accounts[a2].nil?
  accounts[a2] += amount
  @account_set.add(a2) # the account shows up in the latter part of the transaction could be new, add it to sorted set
  negative_set.delete(a2) if accounts[a2] >= 0
end

# check whether the transactions are valid
# transactions is a string contains all transactions and seperated by ':'
# accounts is an array with max size 1000000 that hold the address and balance
def verify_transactions(transactions, accounts, line_number)
  data = transactions.split(':')
  if data.empty?
    puts "Line #{line_number}: transaction list is empty"
    return false
  end

  # verify the pattern of each transaction and apply the transaction to the accounts
  data.each do |trans|
    unless valid_transaction_pattern?(trans)
      puts "Line #{line_number}: Cannot parse transaction '#{trans}'"
      return false
    end

    apply_transaction(trans, accounts, @negative)
  end

  # after processing the whole block, check whether there is any accounts with negative balance
  unless @negative.empty?
    @negative.each do |address|
      puts "Line #{line_number}: Invalid block, address #{address} has #{accounts[address]} billcoins!"
    end
    return false
  end

  true
end

# verify the given line's format and literal data
# compare those data with the previous values like line number, hash, and time
def verify_line(line, prev_line_number, prev_hash, prev_time, accounts)
  values = line.split('|')
  if values.size != 5 # wrong pattern
    puts "Line #{prev_line_number + 1}: Cannot parse the block '#{line}'"
    return [false, nil, nil, nil] if values.size != 5
  end

  line_number = values[0].to_i
  last_hash = values[1]
  transactions = values[2]
  time = values[3]
  curr_hash = values[4][0..-2]

  # verify the block
  if line_number != prev_line_number + 1 # check line number
    puts "Line #{prev_line_number + 1}: Invalid block number #{line_number}, should be #{prev_line_number + 1}"
    return [false, nil, nil, nil]
  elsif last_hash != prev_hash # check whether the hash link is correct
    puts "Line #{line_number}: Previous hash was #{last_hash}, should be #{prev_hash}"
    return [false, nil, nil, nil]
  elsif !greater?(time, prev_time) # check the timestamp
    puts "Line #{line_number}: Previous timestamp #{prev_time} >= new timestamp #{time}"
    return [false, nil, nil, nil]
  elsif !verify_transactions(transactions, accounts, line_number) # check the transactions
    return [false, nil, nil, nil]
  else # everything looks fine
    [true, line_number, curr_hash, time]
  end
end

# show the error in the given line
def show_error_message
  puts 'BLOCKCHAIN INVALID'
end

def show_usage
  puts 'Usage: ruby verifier.rb <name_of_file>'
  puts '       name_of_file = name of file to verify'
end
