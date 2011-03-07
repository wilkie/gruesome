require_relative 'header'
require_relative 'memory'
require_relative 'abbreviation_table'

module Gruesome
	module Z
		class ObjectTable
			def initialize(memory)
				@memory = memory
				@header = Header.new(@memory.contents)
				@abbreviation_table = AbbreviationTable.new(@memory)

				@address = @header.object_tbl_addr

				if @header.version <= 3
					# versions 1-3 have 32 entries
					@num_properties = 31
				else
					# versions 4+ have 32 entries
					@num_properties = 63
				end

				@object_tree_address = @address + @num_properties*2

				if @header.version <= 3
					@attributes_size = 4
					@object_id_size = 1

					# Entry:
					#
					# Attributes (4 bytes)
					# Parent Object ID (1 byte)
					# Sibling Object ID (1 byte)
					# Child Object ID (1 byte)
					# Properties Address (2 bytes)
				else
					@attributes_size = 6
					@object_id_size = 2

					# Entry: (Object IDs are 2 bytes)
					#
					# Attributes (6 bytes)
					# Parent Object ID (2 byte)
					# Sibling Object ID (2 byte)
					# Child Object ID (2 byte)
					# Properties Address (2 bytes)
				end

				@obj_entry_size = @attributes_size + (@object_id_size * 3) + 2

				# Check machine endianess
				@endian = [1].pack('S')[0] == 1 ? 'little' : 'big'
			end

			def property_default(index)
				index -= 1
				index %= @num_properties

				# The first thing in the table is the property defaults list
				# So, simply lookup the 16-bit word at the entry given by index
				prop_default_addr = @address + index*2
				@memory.force_readw(prop_default_addr)
			end

			def object_entry(index)
				index -= 1
				obj_entry_addr = @object_tree_address + (index * @obj_entry_size)

				attributes_address = obj_entry_addr
				cur_addr = attributes_address

				# read the attributes
				attribute_bytes = []
				@attributes_size.times do
					attribute_bytes << @memory.force_readb(cur_addr)
					cur_addr += 1
				end

				# read the object ids of associated objects
				ids = (0..2).map do |i|
					if @object_id_size == 2
						id = @memory.force_readw(cur_addr)
						cur_addr += 2
					else
						id = @memory.force_readb(cur_addr)
						cur_addr += 1
					end
					id
				end

				properties_address = @memory.force_readw(cur_addr)

				# return a hash with the information of the entry
				{	:attributes_address => attributes_address,
					:attributes => attribute_bytes, 
					:parent_id => ids[0], 
					:sibling_id => ids[1], 
					:child_id => ids[2], 
					:properties_address => properties_address	}
			end

			def object_get_child(index)
				object_entry(index)[:child_id]
			end

			def object_get_sibling(index)
				object_entry(index)[:sibling_id]
			end

			def object_get_parent(index)
				object_entry(index)[:parent_id]
			end

			def object_set_child(index, child_id)
				entry = object_entry(index)
				addr = entry[:attributes_address] + @attributes_size + @object_id_size*2

				if @object_id_size == 1
					@memory.force_writeb(addr, child_id)
				else
					@memory.force_writew(addr, child_id)
				end
			end

			def object_set_sibling(index, sibling_id)
				entry = object_entry(index)
				addr = entry[:attributes_address] + @attributes_size + @object_id_size

				if @object_id_size == 1
					@memory.force_writeb(addr, sibling_id)
				else
					@memory.force_writew(addr, sibling_id)
				end
			end

			def object_set_parent(index, parent_id)
				entry = object_entry(index)
				addr = entry[:attributes_address] + @attributes_size

				if @object_id_size == 1
					@memory.force_writeb(addr, parent_id)
				else
					@memory.force_writew(addr, parent_id)
				end
			end

			def object_insert_object(index, new_child)
				#object_set_parent(new_child, index)
				object_set_sibling(new_child, object_get_child(index))
				object_set_child(index, new_child)
			end

			def object_remove_object(index)
				#parent_id = object_get_parent(index)
				#sibling_id = object_get_sibling(index)
				#child_of_parent = object_get_child(parent_id)

				# if the parent's child is this node, we must change it
				#if child_of_parent == index
				#	if sibling_id == index or sibling_id == 0
				#		# our old parent has no children because we were an only child
				#		object_set_child(parent_id, 0)
				#	else
				#		# our parents still have our sibling
				#		object_set_child(parent_id, sibling_id)
				#	end
				#end
				
				object_set_parent(index, 0)
			end

			def object_short_text(index)
				entry = object_entry(index)
				prop_address = entry[:properties_address]

				# text_len is the maximum number of bytes the string can have
				text_len = @memory.force_readb(prop_address) * 2
				chrs = @memory.force_readzstr(prop_address+1, text_len)[1]

				ZSCII.translate(0, @header.version, chrs, @abbreviation_table)
			end

			def attribute_number_to_byte_bit_pair(attribute_number)
				# get the byte and bit number
				#
				# Note: it counts from the MSB, so it has to
				# reverse the bit_number by subtracting from 7
				#
				# That is, attribute  7 is byte 0, bit 0
				#          attribute 17 is byte 2, bit 6
				#          etc

				byte_number = (attribute_number / 8).to_i
				bit_number = attribute_number % 8
				bit_number = 7 - bit_number

				{ :byte => byte_number, :bit => bit_number }
			end
			private :attribute_number_to_byte_bit_pair

			def object_has_attribute?(index, attribute_number)
				entry = object_entry(index)

				location = attribute_number_to_byte_bit_pair(attribute_number)
				attribute_byte = entry[:attributes][location[:byte]]
				mask = 1 << location[:bit]

				(attribute_byte & mask) > 0
			end

			def object_set_attribute(index, attribute_number)
				entry = object_entry(index)

				location = attribute_number_to_byte_bit_pair(attribute_number)
				attribute_byte = entry[:attributes][location[:byte]]
				mask = 1 << location[:bit]

				attribute_byte |= mask

				byte_addr = entry[:attributes_address] + location[:byte]
				@memory.force_writeb(byte_addr, attribute_byte)
			end

			def object_clear_attribute(index, attribute_number)
				entry = object_entry(index)

				location = attribute_number_to_byte_bit_pair(attribute_number)
				attribute_byte = entry[:attributes][location[:byte]]
				mask = 1 << location[:bit]

				attribute_byte &= ~mask

				byte_addr = entry[:attributes_address] + location[:byte]
				@memory.force_writeb(byte_addr, attribute_byte)
			end

			def object_properties(index)
				entry = object_entry(index)
				prop_address = entry[:properties_address]
				
				# get the length of the string in bytes
				text_len = @memory.force_readb(prop_address) * 2
				prop_address += 1

				prop_address += text_len

				properties = {}

				while true do
					if @header.version <= 3
						size = @memory.force_readb(prop_address)
						prop_address += 1

						# when size is 0, this is the end of the list
						if size == 0
							break
						end

						# size is considered 32 times the data size minus one
						# property number is the first 5 bits
						property_number = size & 0b11111

						size = size >> 5
						size += 1
					else
						# in versions 4+, the size and property number are given
						# as two bytes.
						#
						# if bit 7 is set in the first byte:
						#    The second byte is read where first 6 bits 
						#    indicate size, bit 6 is ignored, bit 7 is set
						# if bit 7 is clear in the first byte:
						#    bit 6 is clear = size of 1
						#    bit 6 is set = size of 2
						#
						# property number is first 6 bits of first byte

						first_byte = @memory.force_readb(prop_address)
						prop_address += 1

						property_number = first_byte & 0b111111
						if first_byte & 0b10000000 > 0
							# bit 7 is set
							second_byte = @memory.force_readb(prop_address)
							prop_address += 1

							size = second_byte & 0b111111

							# a size of 0 is allowed, and will indicate a size of 64
							if size == 0
								size = 64
							end
						else
							# bit 7 is clear
							if first_byte & 0b1000000 > 0
								# bit 6 is set
								size = 2
							else
								# bit 6 is clear
								size = 1
							end
						end
					end

					# regardless of version, we now have the property size and the number

					properties[property_number] = {:size => size, :property_data_address => prop_address}
					prop_address += size
				end

				properties
			end

			def object_get_property(index, property_number)
				properties = object_properties(index)

				property_data = []

				property_info = properties[property_number]
				
				if property_info == nil
					property_data = nil
				else
					address = property_info[:property_data_address]
					properties[property_number][:size].times do
						property_data << @memory.force_readb(address)
						address += 1
					end
				end

				property_data
			end

			def object_get_property_addr(index, property_number)
				properties = object_properties(index)

				property_info = properties[property_number]
				
				if property_info == nil
					0
				else
					property_info[:property_data_address]
				end
			end

			def object_get_property_word(index, property_number)
				property_data = object_get_property(index, property_number)
				if property_data == nil
					property_default(property_number)
				elsif property_data.size > 1
					if @endian == 'little'
						(property_data[1] << 8) | property_data[0]
					else
						(property_data[0] << 8) | property_data[1]
					end
				else
					property_data[0]
				end
			end

			def object_set_property_word(index, property_number, value)
				properties = object_properties(index)

				property_info = properties[property_number]

				if property_info == nil
					raise "put_prop attempted to set a property value for a property that did not exist"
				else
					if property_info[:size] == 1
						value &= 0xff
						@memory.force_writeb(property_info[:property_data_address], value)
					elsif property_info[:size] == 2
						@memory.force_writew(property_info[:property_data_address], value)
					else
						raise "put_prop attempted to set a property whose data size is larger than a word"
					end
				end
			end
		end
	end
end
