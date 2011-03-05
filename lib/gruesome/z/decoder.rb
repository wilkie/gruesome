# The Z-Machine has a RISC-like instruction set with 1 byte opcodes with
# the exception of several extension opcodes of 2 bytes.
#
# The operands are variable length, however, mostly for size constraint reasons.
#
# The format:
#
# OPCODE :: 1 or 2 bytes 
# OPCODE_TYPE (opt) :: 1 to 2 bytes, divided into 2-bit fields
# OPERANDS :: 0 to 8 given, each 1 or 2 bytes, or an unlimited length string

require_relative 'opcode'
require_relative 'operand_type'
require_relative 'opcode_class'
require_relative 'instruction'

module Gruesome
	module Z
		
		# This is the instruction decoder
		class Decoder
			def initialize(memory)
				@memory = memory
				@instruction_cache = {}
				@header = Header.new(@memory.contents)
			end

			def decode
				pc = @memory.program_counter
				orig_pc = pc

				# Determine type and form of the operand
				# along with the number of operands

				# read first byte to get opcode
				opcode = @memory.force_readb(pc)
				pc = pc + 1

				# opcode form is top 2 bits
				opcode_form = (opcode >> 6) & 3
				operand_count = 0
				operand_types = Array.new(8) { OperandType::OMITTED }
				operand_values = Array.new(8) { 0 }

				if opcode_form == 2
					# operand count is determined by bits 4 and 5
					if ((opcode >> 4) & 3) == 3
						operand_count = 0
						opcode_class = OpcodeClass::OP0
					else
						operand_count = 1
						opcode_class = OpcodeClass::OP1
					end

					operand_types[0] = (opcode >> 4) & 3

					# opcode is given as bottom 4 bits
					opcode = opcode & 0b1111
				elsif opcode_form == 3
					if (opcode & 0b100000) == 0
						# when bit 5 is clear, there are two operands
						operand_count = 2
						opcode_class = OpcodeClass::OP2
					else
						# otherwise, there are VAR number
						operand_count = 8
						opcode_class = OpcodeClass::VAR
					end

					# opcode is given as bottom 5 bits
					opcode = opcode & 0b11111
				elsif opcode == 190 # extended form
					opcode_form = OpcodeClass::EXT

					# VAR number
					operand_count = 8

					# opcode is given as the next byte
					opcode = @memory.force_readb(pc)
					pc = pc + 1
				else # long form

					# there are always 2 operands
					operand_count = 2
					opcode_form = OpcodeClass::OP2

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
				if opcode_class == OpcodeClass::VAR or opcode_class == OperandForm::EXT
					# each type for the operands is given by reading
					# the next 1 or 2 bytes.
					#
					# This byte contains 4 type descriptions where
					# the most significant 2 bits are the 0th type
					# and the least 2 are the 3rd type
					#
					# If a type is deemed omitted, every subsequent
					# type must also be omitted

					byte = @memory.force_readb(pc)
					pc = pc + 1

					operand_types[0] = (byte >> 6) & 3
					operand_types[1] = (byte >> 4) & 3
					operand_types[2] = (byte >> 2) & 3
					operand_types[3] = byte & 3

					# Get the number of operands
					idx = -1
					first_omitted = -1
					operand_count = operand_types.inject(0) do |result, element|
						idx = idx + 1
						if element == OperandType::OMITTED
							first_omitted = idx
							result
						elsif first_omitted == -1
							result + 1
						else
							# Error, OMITTED was found, but another type
							# was defined as not omitted
							# We will ignore
							result
						end
					end

					if opcode == Opcode::CALL_VS2 or opcode == Opcode::CALL_VN2
						# Certain opcodes can have up to 8 operands!
						# These are given by a second byte
						byte = @memory.force_readb(pc)
						pc = pc + 1

						operand_types[4] = (byte >> 6) & 3
						operand_types[5] = (byte >> 4) & 3
						operand_types[6] = (byte >> 2) & 3
						operand_types[7] = byte & 3

						# update operand_count once more
						operand_count = operand_types.inject(operand_count) do |result, element|
							idx = idx + 1
							if element == OperandType::OMITTED
								first_omitted = idx
								result
							elsif first_omitted == -1
								result + 1
							else
								# Error, OMITTED was found, but another type
								# was defined as not omitted
								# We will ignore
								result
							end
						end
					end
				end

				# Retrieve the operand values
				operand_types.each do |i|
					if i == OperandType::SMALL || OperandType::VARIABLE
						operand_values << @memory.force_readb(pc)
						pc = pc + 1
					elsif i == OperandType::LARGE 
						operand_values << @memory.force_readw(pc)
						pc = pc + 2
					end
				end

				# If the opcode stores, we need to pull the next byte to get the
				# destination of the result
				destination = -1
				if Opcode.is_store?(opcode_class, opcode, @header.version)
					destination = @memory.force_readb(pc)
					pc = pc + 1
				end

				# If the opcode is a branch, we need to pull the offset info
				branch_destination = -1
				branch_condition = false
				if Opcode.is_branch?(opcode_class, opcode, @header.version)
					branch_offset = @memory.force_readb(pc)
					pc = pc + 1

					# if bit 7 is set, the branch occurs on a true condition
					# false otherwise
					if (branch_offset & 0b10000000) != 0
						branch_condition = true
					end

					# if bit 6 is clear, the branch offset is 14 bits (6 from first byte 
					# and the 8 from the next byte) This is _signed_
					if (branch_offset & 0b01000000) == 0
						branch_offset = branch_offset & 0b111111
						branch_offset = branch_offset << 8
						branch_offset = branch_offset | @memory.force_readb(pc)
						pc = pc + 1
					else # otherwise, the offset is simply the remaining 6 bits _unsigned_
						branch_offset = branch_offset & 0b111111
					end

					# calculate actual destination from the offset
					if branch_offset < 2
						# a return
						branch_destination = branch_offset
					else
						branch_destination = pc + branch_offset - 2
					end
				end

				# Create an Instruction class to hold this metadata
				inst = Instruction.new(opcode, opcode_class, operand_types, operand_values, destination, branch_destination, branch_condition)

				# Store in the instruction cache
				@instruction_cache[orig_pc] = inst

				# print out the instruction
				line = "at $" + sprintf("%04x", orig_pc) + ": " + inst.to_s(@header.version)

				line = line + operand_values.inject("") do |result, element|
					result = " " + element.to_s
				end

				if destination != -1
					line = line + " -> " + destination.to_s
				end

				if branch_destination != -1
					line = line + " goto $" + branch_destination + " on " + branch_condition
				end

				puts line
			end
		end
	end
end
