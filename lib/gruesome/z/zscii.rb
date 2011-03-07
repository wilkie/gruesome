module Gruesome
	module Z

		# This translates between the special ZSCII character encoding
		# to ASCII / UNICODE
		module ZSCII

			ALPHABET_TABLES = [
				"abcdefghijklmnopqrstuvwxyz", 
				"ABCDEFGHIJKLMNOPQRSTUVWXYZ", 
				" \n0123456789.,!?_#'\"/\\-:()"
			]

			V1_A2 = " 0123456789.,!?_#'\"/\\<-:()"

			# figure out if a shift lock is pressed and return it
			def ZSCII.eval_alphabet(initial_alphabet, version, codes)
				if version < 3
				else
					initial_alphabet
				end
			end

			# return the utf8 string for the given ZSCII code
			def ZSCII.translate(initial_alphabet, version, zscii_str, abbreviation_table = nil, table = nil)
				str = ""

				alphabet = initial_alphabet

				# for abbreviations
				next_is_abbrev = false
				abbrev_alphabet = 0

				# for 10-bit characters
				next_is_big_char_top = false
				next_is_big_char_bottom = false
				big_char = 0

				zscii_str.each do |c|
					if next_is_big_char_top
						next_is_big_char_top = false
						next_is_big_char_bottom = true

						big_char = c
					elsif next_is_big_char_bottom
						next_is_big_char_bottom = false

						big_char = big_char << 5
						big_char |= c
					elsif next_is_abbrev
						next_is_abbrev = false

						str += abbreviation_table.lookup(abbrev_alphabet, c, alphabet)
					elsif (version < 3 and c == 2) or c == 4
						# handle shift characters
						alphabet = (alphabet + 1) % 3
						if version < 3 and c == 2
							initial_alphabet = alphabet
						end
					elsif (version < 3 and c == 3) or c == 5
						# handle shift characters
						alphabet = (alphabet - 1) % 3
						if version < 3 and c == 3
							initial_alphabet = alphabet
						end
					elsif (version >= 2 and c == 1) or (version >= 3 and (c == 2 or c == 3))
						# the next code will decide the character to pull from the table
						if abbreviation_table != nil
							next_is_abbrev = true
							abbrev_alphabet = c - 1
						end
					else
						# translate character
						if alphabet == 2 and c == 6
							# 10 bit ZSCII code follows
							# next c gives top 5 bits
							# c after that gives bottom 5 bits
							next_is_big_char_top = true
						elsif c == 0 
							# space
							str += " "
						elsif version == 1 and c == 1
							# newline
							str += "\n"
						elsif version == 1 and alphabet == 2
							alphabet_char_idx = c - 6
							str += V1_A2[alphabet_char_idx]
						elsif version <= 4 or table == nil
							# normal translation
							# c will always be > 5 here
							alphabet_char_idx = c - 6
							str += ALPHABET_TABLES[alphabet][alphabet_char_idx]
						elsif version >= 5
							# table is not nil, use it to determine the letter
							# XXX: Use included table (array of three strings)
						end
					end

					if c < 2 or c > 5
						alphabet = initial_alphabet
					end
				end

				return str
			end
		end
	end
end
