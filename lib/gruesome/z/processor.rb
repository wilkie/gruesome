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

			def routine_return(result)
			end

			def execute(instruction)
				case instruction.opcode
				when Opcode::ART_SHIFT
					places = unsigned_to_signed(instruction.operands[1])
					if places < 0
						@memory.writev(instruction.destination, unsigned_to_signed(instruction.operands[0]) >> places.abs)
					else
						@memory.writev(instruction.destination, instruction.operands[0] << places)
					end
				when Opcode::CALL
					if instruction.operands[0] == 0
						# special case, do not call, simply return false
						@memory.writev(instruction.destination, 0)
					else
						return_addr = @memory.program_counter
						routine_addr = @memory.packed_address_to_byte_address(instruction.operands[0])
						@memory.program_counter = routine_addr

						# read routine
						num_locals = @memory.force_readb(@memory.program_counter)
						@memory.program_counter += 1

						puts "routine called at $" + sprintf("%04x", routine_addr) + " with " + num_locals.to_s + " locals"

						# create environment
						@memory.push_routine(return_addr, num_locals)

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
						instruction.operands[1..-1].each do |i|
							@memory.writev(idx, instruction.operands[i])
							idx += 1
						end
					end
				when Opcode::JUMP
					@memory.program_counter += unsigned_to_signed(instruction.operands[0])
					@memory.program_counter -= 2
				when Opcode::JE
					result = instruction.operands[1..-1].inject(false) { |result, element|
						result | (instruction.operands[0] == element)
					}
					if (result == instruction.branch_on)
						puts "old pc " + @memory.program_counter.to_s
						puts "applying " + instruction.branch_to.to_s
						@memory.program_counter += instruction.branch_to
						@memory.program_counter &= 0xffff
						@memory.program_counter -= 2
						puts "new pc " + @memory.program_counter.to_s
					end
				when Opcode::JG
					result = unsigned_to_signed(instruction.operands[0]) > unsigned_to_signed(instruction.operands[1])
					if (result == instruction.branch_on)
						@memory.program_counter += instruction.branch_to
						@memory.program_counter -= 2
					end
				when Opcode::JIN
					# XXX: JIN is an object instruction
				when Opcode::JL
					result = unsigned_to_signed(instruction.operands[0]) < unsigned_to_signed(instruction.operands[1])
					if (result == instruction.branch_on)
						@memory.program_counter += instruction.branch_to
						@memory.program_counter -= 2
					end
				when Opcode::JZ
					result = instruction.operands[0] == 0
					if (result == instruction.branch_on)
						@memory.program_counter += instruction.branch_to
						@memory.program_counter -= 2
					end
				when Opcode::LOAD
					@memory.writev(instruction.destination, @memory.readv(instruction.operands[0]))
				when Opcode::LOADB
					@memory.writev(instruction.destination, @memory.readb(instruction.operands[0] + unsigned_to_signed(instruction.operands[1])))
				when Opcode::LOADW
					@memory.writev(instruction.destination, @memory.readw(instruction.operands[0] + unsigned_to_signed(instruction.operands[1])*2))
				when Opcode::LOG_SHIFT
					places = unsigned_to_signed(instruction.operands[1])
					if places < 0
						@memory.writev(instruction.destination, instruction.operands[0] >> places.abs)
					else
						@memory.writev(instruction.destination, instruction.operands[0] << places)
					end
				when Opcode::NEW_LINE
					puts
				when Opcode::PRINT
					print instruction.operands[0]
				when Opcode::PRINT_ADDR
					print ZSCII.translate(0, @header.version, @memory.force_readzstr(instruction.operands[0], 0)[1])
				when Opcode::PRINT_CHAR
					print ZSCII.translate(0, @header.version, [instruction.operands[0]])
				when Opcode::ADD
					@memory.writev(instruction.destination,
						unsigned_to_signed(instruction.operands[0]) + unsigned_to_signed(instruction.operands[1]))
				when Opcode::SUB
					@memory.writev(instruction.destination,
						unsigned_to_signed(instruction.operands[0]) - unsigned_to_signed(instruction.operands[1]))
				when Opcode::MUL
					@memory.writev(instruction.destination,
						unsigned_to_signed(instruction.operands[0]) * unsigned_to_signed(instruction.operands[1]))
				when Opcode::DIV
					result = unsigned_to_signed(instruction.operands[0]).to_f / unsigned_to_signed(instruction.operands[1]).to_f
					if result < 0
						result = -(result.abs.floor)
					else
						result = result.floor
					end
					@memory.writev(instruction.destination, result.to_i)
				when Opcode::MOD
					a = unsigned_to_signed(instruction.operands[0])
					b = unsigned_to_signed(instruction.operands[1])
					result = a.abs % b.abs
					if a < 0 
						result = -result
					end
					@memory.writev(instruction.destination, result.to_i)
				when Opcode::NOT
					@memory.writev(instruction.destination, ~(instruction.operands[0]))
				when Opcode::OR
					@memory.writev(instruction.destination, instruction.operands[0] | instruction.operands[1])
				when Opcode::AND
					@memory.writev(instruction.destination, instruction.operands[0] & instruction.operands[1])
				when Opcode::STORE
					@memory.writev(instruction.operands[0], instruction.operands[1])
				when Opcode::STOREB
					@memory.writeb(instruction.operands[0] + unsigned_to_signed(instruction.operands[1]), instruction.operands[2])
				when Opcode::STOREW
					@memory.writew(instruction.operands[0] + unsigned_to_signed(instruction.operands[1])*2, instruction.operands[2])
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
