# frozen_string_literal: true

require_relative 'utils'

valid, filename = verify_user_input(ARGV)
if valid
  verify(filename)
elsif filename.nil?
  puts 'Please try again with the file name you want to verify.'
else # file doesn't exist
  puts "File #{filename} doesn't exist."
end
