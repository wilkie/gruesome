module Gruesome
	module Z

		# A Z-Machine instruction
		class Instruction
			attr_reader :opcode
			attr_reader :class
			attr_reader :types
			attr_reader :operands
			attr_reader :destination

			def initialize(opcode, opcode_class, types, operands, destination)
				@opcode = opcode
				@class = opcode_class
				@types = types
				@operands = operands
				@destination = destination
			end
		end
	end
end
