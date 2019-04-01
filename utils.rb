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

# verify whether the given file a valid billchain file
def verify(filename)
  puts filename
  puts 'the method not done yet'
end
