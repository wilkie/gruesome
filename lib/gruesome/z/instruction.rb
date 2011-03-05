module Gruesome
	module Z

		# A Z-Machine instruction
		class Instruction
			attr_reader :opcode			# the opcode
			attr_reader :class			# the opcode class
			attr_reader :types			# the types of the operands
			attr_reader :operands		# the operands given to the instruction
			attr_reader :destination	# the destination variable to place the result
			attr_reader :branch_to		# the address to set the pc when branch is taken 
										#  also... if 0, return true from routine
										#          if 1, return false from routine
			attr_reader :branch_on		# the condition is matched against this

			def initialize(opcode, opcode_class, types, operands, destination, branch_destination, branch_condition)
				@opcode = opcode
				@class = opcode_class
				@types = types
				@operands = operands
				@destination = destination
				@branch_to = branch_destination
				@branch_on = branch_condition
			end

			def to_s(version)
				Opcode.name(@class, @opcode, version)
			end
		end
	end
end