# The Z-Machine has a dictionary which it uses to parse input and
# perform lexical analysis.

# The header is located at the address given in the Header at
# address 0x08

require_relative 'memory'
require_relative 'header'
require_relative 'zscii'

module Gruesome
	module Z
		class Dictionary
			def initialize(memory)
				@memory = memory
				@header = Header.new(@memory.contents)

				@abbreviation_table = AbbreviationTable.new(@memory)

				@lookup_cache = {}
			end

			def address
				@header.dictionary_addr
			end

			def address_of_entries
				addr = self.address
				num_input_codes = @memory.force_readb(addr)
				addr += 1
				addr += num_input_codes
				addr += 3

				addr
			end

			def entry_length
				addr = self.address_of_entries - 3
				return @memory.force_readb(addr)
			end

			def number_of_words
				addr = self.address_of_entries - 2
				return @memory.force_readw(addr)
			end

			def word_address(index)
				addr = address_of_entries
				addr += entry_length * index

				return addr
			end

			def word(index)
				addr = word_address(index)

				codes = nil

				if @header.version <= 3
					codes = @memory.force_readzstr(addr, 4)[1]
				else
					codes = @memory.force_readzstr(addr, 6)[1]
				end

				str = ZSCII.translate(0, @header.version, codes, @abbreviation_table)
				@lookup_cache[str] = index
				return str
			end

			def lookup_word(token)
				cached_index = @lookup_cache[token]
				if cached_index != nil
					if self.word(cached_index) == token
						return cached_index
					end
				end

				number_of_words.times do |i|
					if word(i) == token
						cached_index = i
						break
					end
				end
				
				cached_index
			end

			def word_separators
				addr = self.address

				# the number of word separators
				num_input_codes = @memory.force_readb(addr)
				addr += 1

				codes = []
				num_input_codes.times do
					codes << @memory.force_readb(addr)
					addr += 1
				end

				codes = codes.map do |i|
					ZSCII.translate_Zchar(i)
				end

				return codes
			end

			def tokenize(line)
				orig_line = line

				# I. ensure that word separators are surrounded by spaces
				self.word_separators.each do |sep|
					line = line.gsub(sep, " " + sep + " ")
				end

				# II. break up the line into words delimited by spaces
				tokens = line.split(' ')

				line = orig_line
				last_pos = 0
				ret = tokens.map do |token|
					index = line.index(token)
					line = line[index+token.size..-1]

					index = index + last_pos
					last_pos = index + token.size

					index
					{ :position => index, :string => token }
				end
				
				ret
			end

			def parse(tokens)
				ret = []
				tokens.each do |token|
					index = lookup_word(token[:string])
					if index != nil
						addr = word_address(index)
					else
						addr = 0
					end
					ret << { :size => token[:string].size, :address => addr, :position => token[:position] }
				end

				ret
			end
		end
	end
end
