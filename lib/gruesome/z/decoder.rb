# The Z-Machine has a RISC instruction set with 1 byte opcodes with
# the exception of several extension opcodes of 2 bytes.
#
# The operands are variable length, however, mostly for size constraint reasons.
#
# The format:
#
# OPCODE :: 1 or 2 bytes 
# OPCODE_TYPE (opt) :: 1 to 2 bytes, divided into 2-bit fields
# OPERANDS :: 0 to 8 given, each 1 or 2 bytes, or an unlimited length string

require_relative 'operand_type'
require_relative 'opcode'

module Gruesome
	module Z
		
		# This is the instruction decoder
		class Decoder
			def initialize(memory)
				@memory = memory
			end

			def decode()
				pc = @memory.program_counter

				# Determine type and form of the operand
				# along with the number of operands

				# read first byte to get opcode
				opcode = @memory.readb(pc)
				pc = pc + 1

				# opcode form is top 2 bits
				opcode_form = (opcode >> 6) & 3
				operand_count = 0
				operand_types = Array.new(8) { OperandType::OMITTED }

				if opcode_form == 2 # short form
					# operand count is determined by bits 4 and 5
					if ((opcode >> 4) & 3) == 3
						operand_count = 0
					else
						operand_count = 1
					end

					operand_types[0] = (opcode >> 4) & 3

					# opcode is given as bottom 4 bits
					opcode = opcode & 0b1111
				elsif opcode_form == 3 # variable form
					if (opcode & 0b100000) == 0
						# when bit 5 is clear, there are two operands
						operand_count = 2
					else
						# otherwise, there are VAR number
						operand_count = 8
					end

					# opcode is given as bottom 5 bits
					opcode = opcode & 0b11111
				elsif opcode == 190 # extended form
					opcode_form = 1

					# VAR number
					operand_count = 8

					# opcode is given as the next byte
					opcode = @memory.readb(pc)
					pc = pc + 1
				else # long form
					opcode_form = 0

					# there are always 2 operands
					operand_count = 2

					# bit 6 of opcode is type of operand 1
					type = opcode & 0b1000000
					if type == 0 # 0 means small constant
						type = OperandType::SMALL
					else # 1 means variable
						type = OperandType::VARIABLE 
					end
					operand_types[0] = type

					# bit 5 of opcode is type of operand 2
					type = opcode & 0b100000
					if type == 0 # 0 means small constant
						type = OperandType::SMALL
					else # 1 means variable
						type = OperandType::VARIABLE 
					end
					operand_types[1] = type

					# opcode is given as bottom 5 bits
					opcode = opcode & 0b11111
				end

				# handle VAR operands
				if operand_count == 8
					# each type for the operands is given by reading
					# the next 1 or 2 bytes.
					#
					# This byte contains 4 type descriptions where
					# the most significant 2 bits are the 0th type
					# and the least 2 are the 3rd type
					#
					# If a type is deemed omitted, every subsequent
					# type must also be omitted

					byte = @memory.readb(pc)
					pc = pc + 1

					operand_types[0] = (byte >> 6) & 3
					operand_types[1] = (byte >> 4) & 3
					operand_types[2] = (byte >> 2) & 3
					operand_types[3] = byte & 3

					if opcode == Opcode::CALL_VS2 or opcode == Opcode::CALL_VN2
						# Certain opcodes can have up to 8 operands!
						# These are given by a second byte
						byte = @memory.readb(pc)
						pc = pc + 1

						operand_types[4] = (byte >> 6) & 3
						operand_types[5] = (byte >> 4) & 3
						operand_types[6] = (byte >> 2) & 3
						operand_types[7] = byte & 3
					end
				end
			end

			def execute(instruction)
			end
		end
	end
end
