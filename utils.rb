# frozen_string_literal: true

# given a message of text string in form of utf-8, return the hashed value
# example:
# given 'bill'
# should return 'f896'
def hash_str(message)
  encodings = message.unpack('U*')

  hashed = encodings.map do |x|
    ((x**3000) + (x**x) - (3**x)) * (7**x)
  end

  result = hashed.reduce(0, :+) % 65_536
  result.to_s(16)
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

# verify whether the content of the given file represent a valid billchain
def verify(filename)
  prev_line_number = -1
  prev_hash = '0'
  prev_time = '0'
  accounts = []
  valid_blockchain = true
  File.open(filename).each do |line|
    valid, prev_line_number, prev_hash, prev_time = verify_line(line, prev_line_number, prev_hash, prev_time, accounts)
    # show_error_message(line) unless valid
    unless valid
      show_error_message(line)
      valid_blockchain = false
      break
    end
  end
  if valid_blockchain
    accounts.each_with_index do |account, index|
      puts "#{index}: #{account} billcoins" unless account.nil?
    end
  end
end

# check whether time1 is greater than time2
def greater_time(time1, time2)
  v1 = time1.split('.')
  v2 = time2.split('.')
  return false unless v1.size == 2 || v2.size == 2

  main_value1 = v1[0]
  main_value2 = v2[0]
  return v1[1].to_i > v2[1].to_i if main_value1 == main_value2

  main_value1 > main_value2
end

# check that the given trans str is in the correct patter of transaction record
def valid_transaction_pattern?(trans_str)
  trans_str.match?(/^[0-9]{6}>[0-9]{6}\([0-9]+\)$/) || trans_str.match?(/^SYSTEM>[0-9]{6}\([0-9]+\)$/)
end

# apply a single transaction to accounts
def apply_transaction(transaction, accounts)
  a1 = transaction[0...6]
  a2 = transaction[7...13].to_i
  amount = transaction[14...-1].to_i
  if a1 != 'SYSTEM'
    a1 = a1.to_i
    accounts[a1] = 0 if accounts[a1].nil?
    accounts[a1] -= amount
  end
  accounts[a2] = 0 if accounts[a2].nil?
  accounts[a2] += amount
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

  data.each do |trans|
    unless valid_transaction_pattern?(trans)
      puts "Line #{line_number}: Cannot parse transaction '#{trans}'"
      return false
    end

    apply_transaction(trans, accounts)
  end

  accounts.each_with_index do |account, index|
    if account != nil && account < 0
      puts "Line #{line_number}: Invalid block, address #{index} has #{account} billcoins!"
      return false
    end
    # return false if account != nil && account < 0
  end
  true
end

# verify the given line with the previous values like line number, hash, and time
def verify_line(line, prev_line_number, prev_hash, prev_time, accounts)
  values = line.split('|')
  if values.size != 5
    puts "Line #{prev_line_number + 1}: Cannot parse the block '#{line}'"
    return [false, nil, nil, nil] if values.size != 5
  end

  line_number = values[0].to_i
  last_hash = values[1]
  transactions = values[2]
  time = values[3]
  curr_hash = values[4][0..-2]

  # verify the block
  if line_number != prev_line_number + 1
    puts "Line #{prev_line_number + 1}: Invalid block number #{line_number}, should be #{prev_line_number + 1}"
    return [false, nil, nil, nil]
  elsif last_hash != prev_hash
    puts "Line #{line_number}: Previous hash was #{last_hash}, should be #{prev_hash}"
    return [false, nil, nil, nil]
  elsif !greater_time(time, prev_time)
    puts "Line #{line_number}: Previous timestamp #{prev_time} >= new timestamp #{time}"
    return [false, nil, nil, nil]
  elsif !verify_transactions(transactions, accounts, line_number)
    return [false, nil, nil, nil]
  elsif curr_hash != hash_str("#{line_number}|#{last_hash}|#{transactions}|#{time}")
    str = "#{line_number}|#{last_hash}|#{transactions}|#{time}"
    correct_hash = hash_str(str)
    puts "Line 9: String '#{str}' hash set to #{curr_hash}, should be #{correct_hash}"
    return [false, nil, nil, nil]
  else
    [true, line_number, curr_hash, time]
  end
end

# show the error in the given line
def show_error_message(line)
  # puts line
  puts 'BLOCKCHAIN INVALID'
end

def show_usage
  puts 'Usage: ruby verifier.rb <name_of_file>'
  puts '       name_of_file = name of file to verify'
end
