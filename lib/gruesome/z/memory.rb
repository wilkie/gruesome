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

module Gruesome
	module Z

		# This class holds the memory for the virtual machine
		class Memory
			def initialize(contents)
				@memory = contents

				# Get the header information
				@header = Header.new(@memory)

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
		end
	end
end
