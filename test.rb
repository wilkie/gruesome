require_relative 'lib/gruesome/z/machine'
require_relative 'lib/gruesome/logo'

Gruesome::Logo.print

puts
puts "--------------------------------------------------------------------------------"
puts

m = Gruesome::Z::Machine.new('test/zork1.z3')
