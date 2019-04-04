# frozen_string_literal: true

require_relative 'utils'

valid, filename = verify_user_input(ARGV)
if valid
  verify(filename)
elsif filename.nil?
  show_usage
else # file doesn't exist
  puts "File #{filename} doesn't exist."
end
