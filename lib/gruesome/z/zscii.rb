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

			UNICODE_TRANSLATION_TABLE = {
				155 => "\u00e4", 156 => "\u00f6", 157 => "\u00fc", 158 => "\u00c4", 159 => "\u00d6", 
				160 => "\u00dc", 161 => "\u00df", 162 => "\u00bb", 163 => "\u00ab", 164 => "\u00eb", 
				165 => "\u00ef", 166 => "\u00ff", 167 => "\u00cb", 168 => "\u00cf", 169 => "\u00e1",
				170 => "\u00e9", 171 => "\u00ed", 172 => "\u00f3", 173 => "\u00fa", 174 => "\u00fd",
				175 => "\u00c1", 176 => "\u00c9", 177 => "\u00cd", 178 => "\u00d3", 179 => "\u00da",
				180 => "\u00dd", 181 => "\u00e0", 182 => "\u00e8", 183 => "\u00ec", 184 => "\u00f2",
				185 => "\u00f9", 186 => "\u00c0", 187 => "\u00c8", 188 => "\u00cc", 189 => "\u00d2",
				190 => "\u00d9", 191 => "\u00e2", 192 => "\u00ea", 193 => "\u00ee", 194 => "\u00f4",
				195 => "\u00fb", 196 => "\u00c2", 197 => "\u00ca", 198 => "\u00ce", 199 => "\u00d4",
				200 => "\u00db", 201 => "\u00e5", 202 => "\u00c5", 203 => "\u00f8", 204 => "\u00d8",
				205 => "\u00e3", 206 => "\u00f1", 207 => "\u00f5", 208 => "\u00c3", 209 => "\u00d1",
				210 => "\u00d5", 211 => "\u00e6", 212 => "\u00c6", 213 => "\u00e7", 214 => "\u00c7",
				215 => "\u00fe", 216 => "\u00f0", 217 => "\u00de", 218 => "\u00d0", 219 => "\u00a3",
				220 => "\u0153", 221 => "\u0152", 222 => "\u00a1", 223 => "\u00bf" 
			}

			# figure out if a shift lock is pressed and return it
			def ZSCII.eval_alphabet(initial_alphabet, version, codes)
				if version < 3
				else
					initial_alphabet
				end
			end

			def ZSCII.translate_Zchar(zchar)
				if zchar == 9
					"\t"
				elsif zchar == 11 
					" "
				elsif zchar == 13
					"\n"
				elsif zchar >= 32 and zchar <= 126
					zchar.chr
				elsif zchar >= 155 and zchar <= 223
					UNICODE_TRANSLATION_TABLE[zchar]
				end
			end

			def ZSCII.translate_char_to_zchar(chr, version)
				if chr == "\t"
					9
				elsif chr == " "
					11
				elsif chr == "\n"
					13
				elsif chr.getbyte(0) >= 32 and chr.getbyte(0) <= 126
					chr.getbyte(0)
				else
					# XXX: Unicode Translation Table reversed
					"?".getbyte(0)
				end 
			end

			# Give array of Z-codes
			def ZSCII.translate_char(chr, version)
				ret = []
				if chr >= 'a'[0] and chr <= 'z'[0]
					# A0
					chr = chr.getbyte(0) - 'a'.getbyte(0)
					chr += 6
					ret << chr
				elsif chr >= 'A'[0] and chr <= 'Z'[0]
					# A1
					chr = chr.getbyte(0) - 'A'.getbyte(0)
					chr += 6

					ret << 4
					ret << chr
				elsif chr == " "
					ret << 0
				elsif chr == "\n"
					if version == 1
						# use 10-bit code since newline is not in the alphabet 2
						ret << 5
						ret << 6
						ret << 0
						ret << 13
					else
						ret << 5
						ret << 7
					end
				elsif chr >= '0'[0] and chr <= '9'[0]
					chr = chr[0] - '0'[0]
					if version == 1
						chr += 7
					else
						chr += 8
					end
					ret << 5
					ret << chr
				elsif chr == "."
					ret << 5
					if version == 1
						ret << 17
					else
						ret << 18
					end
				elsif chr == ","
					ret << 5
					if version == 1
						ret << 18
					else	
						ret << 19
					end
				elsif chr == "!"
					ret << 5
					if version == 1
						ret << 19
					else
						ret << 20
					end
				elsif chr == "?"
					ret << 5
					if version == 1
						ret << 20
					else
						ret << 21
					end
				elsif chr == "_"
					ret << 5
					if version == 1
						ret << 21
					else
						ret << 22
					end
				elsif chr == "#"
					ret << 5
					if version == 1
						ret << 22
					else
						ret << 23
					end
				elsif chr == "'"
					ret << 5
					if version == 1
						ret << 23
					else
						ret << 24
					end
				elsif chr == "\""
					ret << 5
					if version == 1
						ret << 24
					else
						ret << 25
					end
				elsif chr == "/"
					ret << 5
					if version == 1
						ret << 25
					else
						ret << 26
					end
				elsif chr == "\\"
					ret << 5
					if version == 1
						ret << 26
					else
						ret << 27
					end
				elsif chr == "<"
					if version == 1
						ret << 5
						ret << 27
					else
						# use 10-bit
						ret << 5
						ret << 6
						ret << 0
						ret << '<'[0]
					end
				elsif chr == "-"
					ret << 5
					ret << 28
				elsif chr == ":"
					ret << 5
					ret << 29
				elsif chr == "("
					ret << 5
					ret << 30
				elsif chr == ")"
					ret << 5
					ret << 30
				end
				# TODO: Unicode

				ret
			end

			def ZSCII.encode_to_zchars(string, version)
				codes = []
				string.each_char do |chr|
					codes << ZSCII.translate_char_to_zchar(chr, version)
				end

				codes
			end

			def ZSCII.encode(string, version)
				codes = []
				string.each_char do |chr|
					subcodes = ZSCII.translate_char(chr, version)
					subcodes.each do |code|
						codes << code
					end
				end

				# pad codes to be divisible by three
				# and pad with '5' shift code
				(codes.length % 3).times do 
					codes << 5
				end
				
				# encode the z-codes
				words = []

				word = 0
				codes.each_with_index do |code, i|
					if (i % 3) == 0
						word = (code & 0b11111) << 10
					elsif (i % 3) == 1
						word |= (code & 0b11111) << 5
					else
						word |= code & 0b11111
						words << word
					end
				end

				# Give single that it is the last word
				words[-1] |= 0b10000000_00000000

				words
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

						str += translate_Zchar(big_char)
					elsif next_is_abbrev
						next_is_abbrev = false

						str += abbreviation_table.lookup(abbrev_alphabet, c, 0)
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
