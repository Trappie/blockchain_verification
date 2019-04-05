# frozen_string_literal: true

require 'flamegraph'
require_relative 'utils.rb'

Flamegraph.generate('current.html') do
  verify('100.txt')
end
