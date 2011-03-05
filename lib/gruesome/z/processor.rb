# The Z-Machine processor unit will execute a stream of Instructions

require_relative 'instruction'
require_relative 'opcode'

module Gruesome
	module Z
		class Processor
			def initialize(memory)
				@memory = memory
			end

			def execute(instruction)
				case instruction.opcode
				when Opcode::JUMP
					@memory.program_counter += unsigned_to_signed(instruction.operands[0])
				end
			end

			def unsigned_to_signed(op)
				sign = op & 0x8000
				op = 65536 - op
				if sign 
					-op
				else
					op
				end
			end
			private :unsigned_to_signed
		end
	end
end
