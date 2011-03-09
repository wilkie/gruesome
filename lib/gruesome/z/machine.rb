require_relative 'header'
require_relative 'memory'
require_relative 'decoder'
require_relative 'processor'
require_relative 'abbreviation_table'
require_relative 'object_table'

module Gruesome
	module Z

		# The class that initializes and maintains a Z-Machine
		class Machine

			# Will create a new virtual machine for the game file
			def initialize(game_file)
				file = File.open(game_file, "r")

				# I. Create memory space

				memory_size = File.size(game_file)
				@memory = Memory.new(file.read(memory_size))

				# Set flags
				flags = @memory.force_readb(0x01)
				flags &= ~(0b1110000)
				@memory.force_writeb(0x01, flags)

				# Set flags 2
				flags = @memory.force_readb(0x10)
				flags &= ~(0b11111100)
				@memory.force_writeb(0x10, flags)

				# II. Read header (at address 0x0000) and associated tables
				@header = Header.new(@memory.contents)
				@object_table = ObjectTable.new(@memory)

				# III. Instantiate CPU
				@decoder = Decoder.new(@memory)
				@processor = Processor.new(@memory)
			end

			def execute
				while true do
					i = @decoder.fetch
					#var = @memory.readv(0)
					#if var != nil
					#	puts "var %00 = " + sprintf("%04x", var)
					#	@memory.writev(0, var)
					#end
					#var = @memory.readv(1)
					#if var != nil
					#	puts "var %01 = " + sprintf("%04x", @memory.readv(0x01))
					#end
					#puts "at $" + sprintf("%04x", @memory.program_counter) + ": " + i.to_s(@header.version)
					@memory.program_counter += i.length

					if i.opcode == Opcode::QUIT
						break
					end

					begin
						@processor.execute(i)
					rescue RuntimeError => fuh
						"error at $" + sprintf("%04x", @memory.program_counter) + ": " + i.to_s(@header.version)
					end
				end
			end
		end
	end
end

