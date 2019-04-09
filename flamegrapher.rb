# frozen_string_literal: true

require 'flamegraph'
require_relative 'utils.rb'

Flamegraph.generate('current.html') do
  verify('long.txt')
end
