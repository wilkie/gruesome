require_relative 'header'

# The Z-Machine Memory is a simple array of bytes
#
# There are three regions: Dynamic, Static, and High
#
# Dynamic Memory can be read and written to by a program
# Static Memory can only be read
# High Memory cannot be accessed by load/store instructions
#
# High Memory can overlap Static, but never Dynamic
#
# Memory is stored in big endian

# Also included as memory space, yet separated from the
# RAM itself: the stack, program counter, local vars ($01 to $0f)
# and item at top of stack (variable $00)

# The stack is weird. Every function call starts with an empty stack
# and any work left in the stack upon a return is lost. So there are
# actually many stacks... one stack to hold the stacks in play, and
# a stack for each active function.

module Gruesome
	module Z

		# This class holds the memory for the virtual machine
		class Memory
			attr_accessor :program_counter

			def initialize(contents)
				@stack = []
				@memory = contents

				# Get the header information
				@header = Header.new(@memory)
				@program_counter = @header.entry

				# With the header info, discover the bounds of each memory region
				@dyn_base = 0x0
				@dyn_limit = @header.static_mem_base

				# Cannot Write to Static Memory
				@static_base = @header.static_mem_base
				@static_limit = @memory.length

				# Cannot Access High Memory
				@high_base = @header.high_mem_base
				@high_limit = @memory.length

				# Error if high memory overlaps dynamic memory
				if @high_base < @dyn_limit
					# XXX: ERROR
				end

				# Check machine endianess
				@endian = [1].pack('S')[0] == 1 ? 'little' : 'big'
			end

			def readb(address)
				if address < @high_base
					force_readb(address)
				else
					# XXX: Access violation
					nil
				end
			end

			def readw(address)
				if (address + 1) < @high_base
					force_readw(address)
				else
					# XXX: Access violation
					nil
				end
			end

			def writeb(address, value)
				if address < @static_base
					force_writeb(address, value)
				else
					# XXX: Access violation
					nil
				end
			end

			def writew(address, value)
				if (address + 1) < @static_base
					force_writew(address, value)
				else
					# XXX: Access violation
					nil
				end
			end

			def force_readb(address)
				if address < @memory.size
					@memory.getbyte(address)
				else
					# XXX: Access Violation
					nil
				end
			end

			def force_readw(address)
				if (address + 1) < @memory.size
					if @endian == 'little'
						(@memory.getbyte(address+1) << 8) | @memory.getbyte(address)
					else
						(@memory.getbyte(address) << 8) | @memory.getbyte(address+1)
					end
				else
					# XXX: Access Violation
					nil
				end
			end

			def force_writeb(address, value)
				if address < @memory.size
					@memory.setbyte(address, (value % 256))
				else
					# XXX: Access Violation
					nil
				end
			end

			def force_writew(address, value)
				if (address + 1) < @memory.size
					low_byte = value % 256
					high_byte = (value >> 8) % 256

					if @endian == 'little'
						tmp = high_byte
						high_byte = low_byte
						low_byte = tmp
					end

					@memory.setbyte(address, high_byte)
					@memory.setbyte(address+1, low_byte)
				else
					# XXX: Access Violation
					nil
				end
			end

			def contents
				@memory
			end

			# Read from variable number index
			def readv(index)
				if index == 0
					# pop from stack
					@stack.pop
				elsif index >= 16
					index -= 16
					readw(@header.global_var_addr + (index*2))
				else
				end
			end

			# Write value to variable number index
			def writev(index, value)
				value %= 65536
				if index == 0
					# push to stack
					@stack.push value
				elsif index >= 16
					index -= 16
					writew(@header.global_var_addr + (index*2), value)
				else
				end
			end
		end
	end
end
