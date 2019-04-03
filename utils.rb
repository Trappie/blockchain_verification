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
  File.open(filename).each do |line|
    valid, prev_line_number, prev_hash, prev_time = verify_line(line, prev_line_number, prev_hash, prev_time, accounts)
    # show_error_message(line) unless valid
    unless valid
      show_error_message(line)
      break
    end
  end
end

# check whether time1 is greater than time2
def greater_time(time1, time2)
  v1 = time1.split('.')
  v2 = time2.split('.')
  return false unless v1.size == 2 || v2.size == 2

  return v1[1] > v2[1] if v1[0] == v2[0]

  v1[0] > v2[0]
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
def varify_transactions(transactions, accounts)
  data = transactions.split(':')
  return false if data.empty?

  data.each do |trans|
    return false unless valid_transaction_pattern?(trans)

    apply_transaction(trans, accounts)
  end

  accounts.each do |account|
    return false if account != nil && account < 0
  end
end

# verify the given line with the previous values like line number, hash, and time
def verify_line(line, prev_line_number, prev_hash, prev_time, accounts)
  values = line.split('|')
  return [false, nil, nil, nil] if values.size != 5

  line_number = values[0].to_i
  last_hash = values[1]
  transactions = values[2]
  time = values[3]
  curr_hash = values[4][0..-2]

  if line_number != prev_line_number + 1
    puts 'line number error'
    return [false, nil, nil, nil]
  elsif last_hash != prev_hash
    puts 'last line hash error'
    return [false, nil, nil, nil]
  elsif !greater_time(time, prev_time)
    puts 'time stamp error'
    return [false, nil, nil, nil]
  elsif !varify_transactions(transactions, accounts)
    puts 'the transactions have error'
    return [false, nil, nil, nil]
  elsif curr_hash != hash_str("#{line_number}|#{last_hash}|#{transactions}|#{time}")
    puts 'current line hash error'
    return [false, nil, nil, nil]
  else
    [true, line_number, curr_hash, time]
  end
end

# show the error in the given line
def show_error_message(line)
  puts line
end
