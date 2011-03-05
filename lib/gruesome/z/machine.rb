require_relative 'header'
require_relative 'memory'
require_relative 'decoder'

module Gruesome
	module Z

		# The class that initializes and maintains a Z-Machine
		class Machine

			# Will create a new virtual machine for the game file
			def initialize(game_file)
				file = File.open(game_file, "r")

				# I. Create memory space

				# The memory space is the size of the file (which is a memory snapshot) or
				# 0x10000, whichever is smaller

				memory_size = [0x10000, file.size].min
				@memory = Memory.new(file.read(memory_size))

				# II. Read header (at address 0x0000)
				@header = Header.new(@memory.contents)

				# III. Instantiate CPU
				@cpu = Decoder.new(@memory)

				100.times do
					i = @cpu.decode
					puts "at $" + sprintf("%04x", @memory.program_counter) + ": " + i.to_s(@header.version)
					@memory.program_counter += i.length
				end
			end
		end
	end
end

