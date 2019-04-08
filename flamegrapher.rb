# frozen_string_literal: true

require 'flamegraph'
require_relative 'utils.rb'

Flamegraph.generate('final.html') do
  verify('long.txt')
end
