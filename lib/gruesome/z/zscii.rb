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

			def ZSCII.translate_Zchar(zchar)
				if zchar == 9
					"\t"
				elsif zchar == 11 
					" "
				elsif zchar == 13
					"\n"
				elsif zchar >= 32 and zchar <= 126
					zchar.chr
				elsif zchar == 155
					"\u00e4"
				elsif zchar == 156
					"\u00f6"
				elsif zchar == 157
					"\u00fc"
				elsif zchar == 158
					"\u00c4"
				elsif zchar == 159
					"\u00d6"
				elsif zchar == 160
					"\u00dc"
				elsif zchar == 161
					"\u00df"
				elsif zchar == 162
					"\u00bb"
				elsif zchar == 163
					"\u00ab"
				elsif zchar == 164
					"\u00eb"
				elsif zchar == 165
					"\u00ef"
				elsif zchar == 166
					"\u00ff"
				elsif zchar == 167
					"\u00cb"
				elsif zchar == 168
					"\u00cf"
				elsif zchar == 169
					"\u00e1"
				elsif zchar == 170
					"\u00e9"
				elsif zchar == 171
					"\u00ed"
				elsif zchar == 172
					"\u00f3"
				elsif zchar == 173
					"\u00fa"
				elsif zchar == 174
					"\u00fd"
				elsif zchar == 175
					"\u00c1"
				elsif zchar == 176
					"\u00c9"
				elsif zchar == 177
					"\u00cd"
				elsif zchar == 178
					"\u00d3"
				elsif zchar == 179
					"\u00da"
				elsif zchar == 180
					"\u00dd"
				elsif zchar == 181
					"\u00e0"
				elsif zchar == 182
					"\u00e8"
				elsif zchar == 183
					"\u00ec"
				elsif zchar == 184
					"\u00f2"
				elsif zchar == 185
					"\u00f9"
				elsif zchar == 186
					"\u00c0"
				elsif zchar == 187
					"\u00c8"
				elsif zchar == 188
					"\u00cc"
				elsif zchar == 189
					"\u00d2"
				elsif zchar == 190
					"\u00d9"
				elsif zchar == 191
					"\u00e2"
				elsif zchar == 192
					"\u00ea"
				elsif zchar == 193
					"\u00ee"
				elsif zchar == 194
					"\u00f4"
				elsif zchar == 195
					"\u00fb"
				elsif zchar == 196
					"\u00c2"
				elsif zchar == 197
					"\u00ca"
				elsif zchar == 198
					"\u00ce"
				elsif zchar == 199
					"\u00d4"
				elsif zchar == 200
					"\u00db"
				elsif zchar == 201
					"\u00e5"
				elsif zchar == 202
					"\u00c5"
				elsif zchar == 203
					"\u00f8"
				elsif zchar == 204
					"\u00d8"
				elsif zchar == 205
					"\u00e3"
				elsif zchar == 206
					"\u00f1"
				elsif zchar == 207
					"\u00f5"
				elsif zchar == 208
					"\u00c3"
				elsif zchar == 209
					"\u00d1"
				elsif zchar == 210
					"\u00d5"
				elsif zchar == 211
					"\u00e6"
				elsif zchar == 212
					"\u00c6"
				elsif zchar == 213
					"\u00e7"
				elsif zchar == 214
					"\u00c7"
				elsif zchar == 215
					"\u00fe"
				elsif zchar == 216
					"\u00f0"
				elsif zchar == 217
					"\u00de"
				elsif zchar == 218
					"\u00d0"
				elsif zchar == 219
					"\u00a3"
				elsif zchar == 220
					"\u0153"
				elsif zchar == 221
					"\u0152"
				elsif zchar == 222
					"\u00a1"
				elsif zchar == 223
					"\u00bf"
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

						str += translate_Zchar(big_char)
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
