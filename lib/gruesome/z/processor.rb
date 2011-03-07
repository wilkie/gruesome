# The Z-Machine processor unit will execute a stream of Instructions

require_relative 'instruction'
require_relative 'opcode'
require_relative 'header'
require_relative 'zscii'

module Gruesome
	module Z
		class Processor
			def initialize(memory)
				@memory = memory
				@header = Header.new(@memory.contents)
			end

			def routine_call(address, arguments, result_variable = nil)
				if address == 0
					# special case, do not call, simply return false
					if result_variable != nil
						@memory.writev(result_variable, 0)
					end
				else
					return_addr = @memory.program_counter
					@memory.program_counter = address

					# read routine
					num_locals = @memory.force_readb(@memory.program_counter)
					@memory.program_counter += 1

					# create environment
					@memory.push_routine(return_addr, num_locals, result_variable)

					if @header.version <= 4
						# read initial values when version 1-4
						(1..num_locals).each do |i|
							@memory.writev(i, @memory.readw(@memory.program_counter))
							@memory.program_counter += 2
						end
					else
						# reset local vars to 0
						(1..num_locals).each do |i|
							@memory.writev(i, 0)
						end
					end

					# copy arguments over into locals
					idx = 1
					arguments.each do |i|
						@memory.writev(idx, i)
						idx += 1
					end
				end
			end

			def routine_return(result)
				frame = @memory.pop_routine

				if frame[:destination] != nil
					@memory.writev(frame[:destination], result)
				end
				@memory.program_counter = frame[:return_address]
			end

			def execute(instruction)
				# TODO: Replace VARIABLE types with the values of the VARIABLE at that location

				# there are some exceptions
				if instruction.opcode == Opcode::STORE
					operands = instruction.operands
				else
					operands = instruction.operands.each_with_index.map do |operand, idx|
						if instruction.types[idx] == OperandType::VARIABLE
							@memory.readv(operand)
						else
							operand
						end
					end
				end

				case instruction.opcode
				when Opcode::ART_SHIFT
					places = unsigned_to_signed(operands[1])
					if places < 0
						@memory.writev(instruction.destination, unsigned_to_signed(operands[0]) >> places.abs)
					else
						@memory.writev(instruction.destination, operands[0] << places)
					end
				when Opcode::CALL, Opcode::CALL_1N
					routine_call(@memory.packed_address_to_byte_address(operands[0]), operands[1..-1], instruction.destination)
				when Opcode::JUMP
					@memory.program_counter += unsigned_to_signed(operands[0])
					@memory.program_counter -= 2
				when Opcode::JE
					result = operands[1..-1].inject(false) { |result, element|
						result | (operands[0] == element)
					}
					if (result == instruction.branch_on)
						@memory.program_counter += instruction.branch_to
						@memory.program_counter &= 0xffff
						@memory.program_counter -= 2
					end
				when Opcode::JG
					result = unsigned_to_signed(operands[0]) > unsigned_to_signed(operands[1])
					if (result == instruction.branch_on)
						@memory.program_counter += instruction.branch_to
						@memory.program_counter -= 2
					end
				when Opcode::JIN
					# XXX: JIN is an object instruction
				when Opcode::JL
					result = unsigned_to_signed(operands[0]) < unsigned_to_signed(operands[1])
					if (result == instruction.branch_on)
						@memory.program_counter += instruction.branch_to
						@memory.program_counter -= 2
					end
				when Opcode::JZ
					result = operands[0] == 0
					if (result == instruction.branch_on)
						@memory.program_counter += instruction.branch_to
						@memory.program_counter -= 2
					end
				when Opcode::LOAD
					@memory.writev(instruction.destination, operands[0])
				when Opcode::LOADB
					@memory.writev(instruction.destination, @memory.readb(operands[0] + unsigned_to_signed(operands[1])))
				when Opcode::LOADW
					@memory.writev(instruction.destination, @memory.readw(operands[0] + unsigned_to_signed(operands[1])*2))
				when Opcode::LOG_SHIFT
					places = unsigned_to_signed(operands[1])
					if places < 0
						@memory.writev(instruction.destination, operands[0] >> places.abs)
					else
						@memory.writev(instruction.destination, operands[0] << places)
					end
				when Opcode::NEW_LINE
					puts
				when Opcode::PRINT
					print operands[0]
				when Opcode::PRINT_ADDR
					print ZSCII.translate(0, @header.version, @memory.force_readzstr(operands[0], 0)[1])
				when Opcode::PRINT_CHAR
					print ZSCII.translate(0, @header.version, [operands[0]])
				when Opcode::RET
					routine_return(operands[0])
				when Opcode::RTRUE
					routine_return(1)
				when Opcode::RFALSE
					routine_return(0)
				when Opcode::TEST
					result = (operands[0] & operands[1]) == operands[1]
					if (result == instruction.branch_on)
						@memory.program_counter += instruction.branch_to
						@memory.program_counter -= 2
					end
				when Opcode::ADD
					@memory.writev(instruction.destination,
						unsigned_to_signed(operands[0]) + unsigned_to_signed(operands[1]))
				when Opcode::SUB
					@memory.writev(instruction.destination,
						unsigned_to_signed(operands[0]) - unsigned_to_signed(operands[1]))
				when Opcode::MUL
					@memory.writev(instruction.destination,
						unsigned_to_signed(operands[0]) * unsigned_to_signed(operands[1]))
				when Opcode::DIV
					result = unsigned_to_signed(operands[0]).to_f / unsigned_to_signed(operands[1]).to_f
					if result < 0
						result = -(result.abs.floor)
					else
						result = result.floor
					end
					@memory.writev(instruction.destination, result.to_i)
				when Opcode::MOD
					a = unsigned_to_signed(operands[0])
					b = unsigned_to_signed(operands[1])
					result = a.abs % b.abs
					if a < 0 
						result = -result
					end
					@memory.writev(instruction.destination, result.to_i)
				when Opcode::NOT
					@memory.writev(instruction.destination, ~(operands[0]))
				when Opcode::OR
					@memory.writev(instruction.destination, operands[0] | operands[1])
				when Opcode::AND
					@memory.writev(instruction.destination, operands[0] & operands[1])
				when Opcode::STORE
					@memory.writev(operands[0], operands[1])
				when Opcode::STOREB
					@memory.writeb(operands[0] + unsigned_to_signed(operands[1]), operands[2])
				when Opcode::STOREW
					@memory.writew(operands[0] + unsigned_to_signed(operands[1])*2, operands[2])
				end
			end

			def unsigned_to_signed(op)
				sign = op & 0x8000
				if sign != 0
					-(65536 - op)
				else
					op
				end
			end
			private :unsigned_to_signed
		end
	end
end
