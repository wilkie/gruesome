require_relative 'opcode_class'

module Gruesome
	module Z
		module Opcode

			# 2OP
			
			JE				= (0x01 << 3) | OpcodeClass::OP2
			JL				= (0x02 << 3) | OpcodeClass::OP2
			JG				= (0x03 << 3) | OpcodeClass::OP2
			DEC_CHK			= (0x04 << 3) | OpcodeClass::OP2
			INC_CHK			= (0x05 << 3) | OpcodeClass::OP2
			JIN				= (0x06 << 3) | OpcodeClass::OP2
			TEST			= (0x07 << 3) | OpcodeClass::OP2
			OR				= (0x08 << 3) | OpcodeClass::OP2
			AND				= (0x09 << 3) | OpcodeClass::OP2
			TEST_ATTR		= (0x0a << 3) | OpcodeClass::OP2
			SET_ATTR		= (0x0b << 3) | OpcodeClass::OP2
			CLEAR_ATTR		= (0x0c << 3) | OpcodeClass::OP2
			STORE			= (0x0d << 3) | OpcodeClass::OP2
			INSERT_OBJ		= (0x0e << 3) | OpcodeClass::OP2
			LOADW			= (0x0f << 3) | OpcodeClass::OP2
			LOADB			= (0x10 << 3) | OpcodeClass::OP2
			GET_PROP		= (0x11 << 3) | OpcodeClass::OP2
			GET_PROP_ADDR	= (0x12 << 3) | OpcodeClass::OP2
			GET_NPROP		= (0x13 << 3) | OpcodeClass::OP2
			ADD				= (0x14 << 3) | OpcodeClass::OP2
			SUB				= (0x15 << 3) | OpcodeClass::OP2
			MUL				= (0x16 << 3) | OpcodeClass::OP2
			DIV				= (0x17 << 3) | OpcodeClass::OP2
			MOD				= (0x18 << 3) | OpcodeClass::OP2
			CALL_2S			= (0x19 << 3) | OpcodeClass::OP2
			CALL_2N			= (0x1a << 3) | OpcodeClass::OP2
			SET_COLOUR		= (0x1b << 3) | OpcodeClass::OP2
			THROW			= (0x1c << 3) | OpcodeClass::OP2

			# 1OP

			JZ				= (0x00 << 3) | OpcodeClass::OP1
			GET_SIBLING		= (0x01 << 3) | OpcodeClass::OP1
			GET_CHILD		= (0x02 << 3) | OpcodeClass::OP1
			GET_PARENT		= (0x03 << 3) | OpcodeClass::OP1
			GET_PROP_LEN	= (0x04 << 3) | OpcodeClass::OP1
			INC				= (0x05 << 3) | OpcodeClass::OP1
			DEC				= (0x06 << 3) | OpcodeClass::OP1
			PRINT_ADDR		= (0x07 << 3) | OpcodeClass::OP1
			CALL_1S			= (0x08 << 3) | OpcodeClass::OP1
			REMOVE_OBJ		= (0x09 << 3) | OpcodeClass::OP1
			PRINT_OBJ		= (0x0a << 3) | OpcodeClass::OP1
			RET				= (0x0b << 3) | OpcodeClass::OP1
			JUMP			= (0x0c << 3) | OpcodeClass::OP1
			PRINT_PADDR		= (0x0d << 3) | OpcodeClass::OP1
			LOAD			= (0x0e << 3) | OpcodeClass::OP1
			NOT_2			= (0x0f << 3) | OpcodeClass::OP1 # version 1-4
			CALL_1N			= (0x0f << 3) | OpcodeClass::OP1 # version 5

			# 0OP
			
			RTRUE			= (0x00 << 3) | OpcodeClass::OP0
			RFALSE			= (0x01 << 3) | OpcodeClass::OP0
			PRINT			= (0x02 << 3) | OpcodeClass::OP0
			PRINT_RET		= (0x03 << 3) | OpcodeClass::OP0
			NOP				= (0x04 << 3) | OpcodeClass::OP0
			SAVE			= (0x05 << 3) | OpcodeClass::OP0
			RESTORE			= (0x06 << 3) | OpcodeClass::OP0
			RESTART			= (0x07 << 3) | OpcodeClass::OP0
			RET_POPPED		= (0x08 << 3) | OpcodeClass::OP0
			POP				= (0x09 << 3) | OpcodeClass::OP0 # version 1
			CATCH			= (0x09 << 3) | OpcodeClass::OP0 # version 5/6
			QUIT			= (0x0a << 3) | OpcodeClass::OP0
			NEW_LINE		= (0x0b << 3) | OpcodeClass::OP0
			SHOW_STATUS		= (0x0c << 3) | OpcodeClass::OP0 # version 3
			VERIFY			= (0x0d << 3) | OpcodeClass::OP0 # version 3
			EXTENDED		= (0x0e << 3) | OpcodeClass::OP0
			PIRACY			= (0x0f << 3) | OpcodeClass::OP0 # version 5/-

			# VAR

			CALL			= (0x00 << 3) | OpcodeClass::VAR # version 1
			CALL_VS			= (0x00 << 3) | OpcodeClass::VAR # version 4
			STOREW			= (0x01 << 3) | OpcodeClass::VAR
			STOREB			= (0x02 << 3) | OpcodeClass::VAR
			PUT_PROP		= (0x03 << 3) | OpcodeClass::VAR
			SREAD			= (0x04 << 3) | OpcodeClass::VAR # version 1 (4 changes semantics)
			AREAD			= (0x04 << 3) | OpcodeClass::VAR # version 5
			PRINT_CHAR		= (0x05 << 3) | OpcodeClass::VAR
			PRINT_NUM		= (0x06 << 3) | OpcodeClass::VAR
			RANDOM			= (0x07 << 3) | OpcodeClass::VAR
			PUSH			= (0x08 << 3) | OpcodeClass::VAR
			PULL			= (0x09 << 3) | OpcodeClass::VAR
			SPLIT_WINDOW	= (0x0a << 3) | OpcodeClass::VAR
			SET_WINDOW		= (0x0b << 3) | OpcodeClass::VAR
			CALL_VS2		= (0x0c << 3) | OpcodeClass::VAR
			ERASE_WINDOW	= (0x0d << 3) | OpcodeClass::VAR
			ERASE_LINE		= (0x0e << 3) | OpcodeClass::VAR
			SET_CURSOR		= (0x0f << 3) | OpcodeClass::VAR
			GET_CURSOR		= (0x10 << 3) | OpcodeClass::VAR
			SET_TSTYLE		= (0x11 << 3) | OpcodeClass::VAR
			BUFFER_MODE		= (0x12 << 3) | OpcodeClass::VAR
			OUTPUT_STREAM	= (0x13 << 3) | OpcodeClass::VAR
			INPUT_STREAM	= (0x14 << 3) | OpcodeClass::VAR
			SOUND_EFFECT	= (0x15 << 3) | OpcodeClass::VAR
			READ_CHAR		= (0x16 << 3) | OpcodeClass::VAR
			SCAN_TABLE		= (0x17 << 3) | OpcodeClass::VAR
			NOT				= (0x18 << 3) | OpcodeClass::VAR # version 5/6
			CALL_VN			= (0x19 << 3) | OpcodeClass::VAR
			CALL_VN2		= (0x1a << 3) | OpcodeClass::VAR
			TOKENIZE		= (0x1b << 3) | OpcodeClass::VAR
			ENCODE_TEXT		= (0x1c << 3) | OpcodeClass::VAR
			COPY_TABLE		= (0x1d << 3) | OpcodeClass::VAR
			PRINT_TABLE		= (0x1e << 3) | OpcodeClass::VAR
			CHECK_ARG_COUNT	= (0x1f << 3) | OpcodeClass::VAR

			SAVE_EXT		= (0x00 << 3) | OpcodeClass::EXT
			RESTORE_EXT		= (0x01 << 3) | OpcodeClass::EXT
			LOG_SHIFT		= (0x02 << 3) | OpcodeClass::EXT
			ART_SHIFT		= (0x03 << 3) | OpcodeClass::EXT
			SET_FONT		= (0x04 << 3) | OpcodeClass::EXT
			DRAW_PICTURE 	= (0x05 << 3) | OpcodeClass::EXT
			PICTURE_DATA 	= (0x06 << 3) | OpcodeClass::EXT
			ERASE_PICTURE 	= (0x07 << 3) | OpcodeClass::EXT
			SET_MARGINS		= (0x08 << 3) | OpcodeClass::EXT
			SAVE_UNDO		= (0x09 << 3) | OpcodeClass::EXT
			RESTORE_UNDO 	= (0x0a << 3) | OpcodeClass::EXT
			PRINT_UNICODE 	= (0x0b << 3) | OpcodeClass::EXT
			CHECK_UNICODE 	= (0x0c << 3) | OpcodeClass::EXT
			MOVE_WINDOW 	= (0x10 << 3) | OpcodeClass::EXT
			WINDOW_SIZE 	= (0x11 << 3) | OpcodeClass::EXT
			WINDOW_STYLE 	= (0x12 << 3) | OpcodeClass::EXT
			GET_WIND_PROP 	= (0x13 << 3) | OpcodeClass::EXT
			SCROLL_WINDOW 	= (0x14 << 3) | OpcodeClass::EXT
			POP_STACK 		= (0x15 << 3) | OpcodeClass::EXT
			READ_MOUSE 		= (0x16 << 3) | OpcodeClass::EXT
			MOUSE_WINDOW 	= (0x17 << 3) | OpcodeClass::EXT
			PUSH_STACK 		= (0x18 << 3) | OpcodeClass::EXT
			PUT_WIND_PROP 	= (0x19 << 3) | OpcodeClass::EXT
			PRINT_FORM		= (0x1a << 3) | OpcodeClass::EXT
			MAKE_MENU		= (0x1b << 3) | OpcodeClass::EXT
			PICTURE_TABLE 	= (0x1c << 3) | OpcodeClass::EXT
		end

		def Opcode.has_string?(opcode, version)
			opcode_class = opcode & 7

			result = false
			if opcode_class == OpcodeClass::OP0
				case opcode
				when Opcode::PRINT, Opcode::PRINT_RET
					result = true
				end
			end

			result
		end

		def Opcode.is_store?(opcode, version)
			opcode_class = opcode & 7

			result = false
			if opcode_class == OpcodeClass::OP2
				case opcode
				when Opcode::OR, Opcode::AND, Opcode::LOADB, Opcode::LOADW,
					Opcode::GET_PROP, Opcode::GET_PROP_ADDR, Opcode::GET_NPROP,
					Opcode::ADD, Opcode::SUB, Opcode::MUL, Opcode::DIV, Opcode::MOD,
					Opcode::CALL_2S
					result = true
				end
			elsif opcode_class == OpcodeClass::OP1
				case opcode
				when Opcode::GET_SIBLING, Opcode::GET_CHILD, Opcode::GET_PARENT,
					Opcode::GET_PROP_LEN, Opcode::CALL_1S
					result = true
				end

				if version < 5
					case opcode
					when Opcode::NOT
						result = true
					end
				end
			elsif opcode_class == OpcodeClass::OP0
				case opcode
				when Opcode::SAVE, Opcode::RESTORE, Opcode::CATCH
					result = true
				end
			elsif opcode_class == OpcodeClass::VAR
				case opcode
				when Opcode::CALL, Opcode::RANDOM, Opcode::CALL_VS2, 
					Opcode::READ_CHAR, Opcode::SCAN_TABLE, Opcode::NOT_2
					result = true
				end

				if version >= 5
					if opcode == Opcode::AREAD
						result = true
					end
				end
			end

			result
		end

		def Opcode.is_variable_by_reference?(opcode, version)
			case opcode
			when Opcode::PULL, Opcode::STORE, 
					Opcode::INC, Opcode::DEC,
					Opcode::DEC_CHK, Opcode::INC_CHK
				return true
			end
			return false
		end

		def Opcode.is_valid?(opcode, version)
			opcode_class = opcode & 7

			result = true
			if opcode_class == OpcodeClass::OP0
				case opcode
				when Opcode::SAVE
					result = false if version < 5
				when Opcode::RESTORE
					result = false if version < 5
				when Opcode::SHOW_STATUS
					result = false if version < 3
				when Opcode::VERIFY
					result = false if version < 3
				when Opcode::PIRACY
					result = false if version < 5
				end
			elsif opcode_class == OpcodeClass::OP1
				case opcode
				when Opcode::CALL_1S
					result = false if version < 4
				end
			elsif opcode_class == OpcodeClass::OP2
				case opcode
				when Opcode::CALL_2S
					result = false if version < 4
				when Opcode::CALL_2N
					result = false if version < 5
				when Opcode::SET_COLOUR
					result = false if version < 5
				when Opcode::THROW
					result = false if version < 5
				end

				if (opcode >> 3) > 0x1c or (opcode >> 3) == 0x00
					result = false
				end
			elsif opcode_class == OpcodeClass::VAR
				case opcode
				when Opcode::SPLIT_WINDOW
					result = false if version < 3
				when Opcode::SET_WINDOW
					result = false if version < 3
				when Opcode::CALL_VS2
					result = false if version < 4
				when Opcode::ERASE_WINDOW
					result = false if version < 4
				when Opcode::ERASE_LINE
					result = false if version < 4
				when Opcode::SET_CURSOR
					result = false if version < 4
				when Opcode::GET_CURSOR
					result = false if version < 4
				when Opcode::SET_TSTYLE
					result = false if version < 4
				when Opcode::BUFFER_MODE
					result = false if version < 4
				when Opcode::OUTPUT_STREAM
					result = false if version < 3
				when Opcode::INPUT_STREAM
					result = false if version < 3
				when Opcode::SOUND_EFFECT
					result = false if version < 5
				when Opcode::READ_CHAR
					result = false if version < 4
				when Opcode::SCAN_TABLE
					result = false if version < 4
				when Opcode::NOT_2
					result = false if version < 5
				when Opcode::CALL_VN
					result = false if version < 5
				when Opcode::CALL_VN2
					result = false if version < 5
				when Opcode::TOKENIZE
					result = false if version < 5
				when Opcode::ENCODE_TEXT
					result = false if version < 5
				when Opcode::COPY_TABLE
					result = false if version < 5
				when Opcode::PRINT_TABLE
					result = false if version < 5
				when Opcode::CHECK_ARG_COUNT
					result = false if version < 5
				end
			elsif opcode_class == OpcodeClass::EXT
				result = false if version < 5

				case opcode
				when Opcode::SAVE_TABLE, EXT_RESTORE_TABLE, EXT_LOG_SHIFT,
						ART_SHIFT, EXT_SET_FONT, EXT_SAVE_UNDO, EXT_RESTORE_UNDO,
						PRINT_UNICODE, EXT_CHECK_UNICODE
				else
					result = false if version < 6
				end
			end
			result
		end

		def Opcode.is_branch?(opcode, version)
			opcode_class = opcode & 7
			if not is_valid?(opcode, version)
				return false
			end

			result = false
			if opcode_class == OpcodeClass::OP0
				case opcode
				when Opcode::SAVE
					if version < 4
						result = true
					end
				when Opcode::RESTORE
					if version < 4
						result = true
					end
				when Opcode::VERIFY, Opcode::PIRACY
					result = true
				end
			elsif opcode_class == OpcodeClass::OP1
				case opcode
				when Opcode::JZ, Opcode::GET_SIBLING, Opcode::GET_CHILD
					result = true
				end
			elsif opcode_class == OpcodeClass::OP2
				case opcode
				when Opcode::JE, Opcode::JL, Opcode::JG, 
						Opcode::DEC_CHK, Opcode::INC_CHK, Opcode::JIN,
						Opcode::TEST, Opcode::TEST_ATTR
					result = true
				end
			elsif opcode_class == OpcodeClass::VAR
				case opcode
				when Opcode::SCAN_TABLE, Opcode::CHECK_ARG_COUNT
					result = true
				end
			elsif opcode_class == OpcodeClass::EXT
				case opcode
				when Opcode::PICTURE_DATA, 
						Opcode::PUSH_STACK, Opcode::MAKE_MENU
					result = true
				end
			end

			result
		end

		def Opcode.name(opcode, version)
			opcode_class = opcode & 7
			if not is_valid?(opcode, version)
				"invalid"
			elsif opcode_class == OpcodeClass::OP0
				case opcode
				when Opcode::RTRUE then "rtrue"
				when Opcode::RFALSE then "rfalse"
				when Opcode::PRINT then "print"
				when Opcode::PRINT_RET then "print_ret"
				when Opcode::NOP then "nop"
				when Opcode::SAVE then "save"
				when Opcode::RESTORE then "restore"
				when Opcode::RESTART then "restart"
				when Opcode::RET_POPPED then "ret_popped"
				when Opcode::POP, Opcode::CATCH
					if version <= 4
						"pop"
					else
						"catch"
					end
				when Opcode::QUIT then "quit"
				when Opcode::NEW_LINE then "new_line"
				when Opcode::SHOW_STATUS then "show_status"
				when Opcode::VERIFY then "verify"
				when Opcode::PIRACY then "piracy"
				end
			elsif opcode_class == OpcodeClass::OP1
				case opcode
				when Opcode::JZ then "jz"
				when Opcode::GET_SIBLING then "get_sibling"
				when Opcode::GET_CHILD then "get_child"
				when Opcode::GET_PARENT then "get_parent"
				when Opcode::GET_PROP_LEN then "get_prop_len"
				when Opcode::INC then "inc"
				when Opcode::DEC then "dec"
				when Opcode::PRINT_ADDR then "print_addr"
				when Opcode::CALL_1S then "call_1s"
				when Opcode::REMOVE_OBJ then "remove_obj"
				when Opcode::PRINT_OBJ then "print_obj"
				when Opcode::RET then "ret"
				when Opcode::JUMP then "jump"
				when Opcode::PRINT_PADDR then "print_paddr"
				when Opcode::LOAD then "load"
				when Opcode::NOT, CALL_1N
					if version <= 4
						"not"
					else
						"call_1n"
					end
				end
			elsif opcode_class == OpcodeClass::OP2
				case opcode
				when Opcode::JE then "je"
				when Opcode::JL then "jl"
				when Opcode::JG then "jg"
				when Opcode::DEC_CHK then "dec_chk"
				when Opcode::INC_CHK then "inc_chk"
				when Opcode::JIN then "jin"
				when Opcode::TEST then "test"
				when Opcode::OR then "or"
				when Opcode::AND then "and"
				when Opcode::TEST_ATTR then "test_attr"
				when Opcode::SET_ATTR then "set_attr"
				when Opcode::CLEAR_ATTR then "clear_attr"
				when Opcode::STORE then "store"
				when Opcode::INSERT_OBJ then "insert_obj"
				when Opcode::LOADW then "loadw"
				when Opcode::LOADB then "loadb"
				when Opcode::GET_PROP then "get_prop"
				when Opcode::GET_PROP_ADDR then "get_prop_addr"
				when Opcode::GET_NPROP then "get_next_prop"
				when Opcode::ADD then "add"
				when Opcode::SUB then "sub"
				when Opcode::MUL then "mul"
				when Opcode::DIV then "div"
				when Opcode::MOD then "mod"
				when Opcode::CALL_2S then "call_2s"
				when Opcode::CALL_2N then "call_2n"
				when Opcode::SET_COLOUR then "set_colour"
				when Opcode::THROW then "throw"
				end
			elsif opcode_class == OpcodeClass::VAR
				case opcode
				when Opcode::CALL, Opcode::CALL_VS
					if version < 4
						"call"
					else
						"call_vs"
					end
				when Opcode::STOREW then "storew"
				when Opcode::STOREB then "storeb"
				when Opcode::PUT_PROP then "put_prop"
				when Opcode::SREAD, Opcode::AREAD
					if version < 5
						"sread"
					else
						"aread"
					end
				when Opcode::PRINT_CHAR then "print_char"
				when Opcode::PRINT_NUM then "print_num"
				when Opcode::RANDOM then "random"
				when Opcode::PUSH then "push"
				when Opcode::PULL then "pull"
				when Opcode::SPLIT_WINDOW then "split_window"
				when Opcode::SET_WINDOW then "set_window"
				when Opcode::CALL_VS2 then "call_vs2"
				when Opcode::ERASE_WINDOW then "erase_window"
				when Opcode::ERASE_LINE then "erase_line"
				when Opcode::SET_CURSOR then "set_cursor"
				when Opcode::GET_CURSOR then "get_cursor"
				when Opcode::SET_TSTYLE then "set_text_style"
				when Opcode::BUFFER_MODE then "buffer_mode"
				when Opcode::OUTPUT_STREAM then "output_stream"
				when Opcode::INPUT_STREAM then "input_stream"
				when Opcode::SOUND_EFFECT then "sound_effect"
				when Opcode::READ_CHAR then "read_char"
				when Opcode::SCAN_TABLE then "scan_table"
				when Opcode::NOT_2 then "not"
				when Opcode::CALL_VN then "call_vn"
				when Opcode::CALL_VN2 then "call_vn2"
				when Opcode::TOKENIZE then "tokenize"
				when Opcode::ENCODE_TEXT then "encode_text"
				when Opcode::COPY_TABLE then "copy_table"
				when Opcode::PRINT_TABLE then "print_table"
				when Opcode::CHECK_ARG_COUNT then "check_arg_count"
				end
			elsif opcode_class == OpcodeClass::EXT
				case opcode
				when Opcode::SAVE_TABLE then "save_table"
				when Opcode::RESTORE_TABLE then "restore_table"
				when Opcode::LOG_SHIFT then "log_shift"
				when Opcode::ART_SHIFT then "art_shift"
				when Opcode::SET_FONT then "set_font"
				when Opcode::DRAW_PICTURE then "draw_picture"
				when Opcode::PICTURE_DATA then "picture_data"
				when Opcode::ERASE_PICTURE then "erase_picture"
				when Opcode::SET_MARGINS then "set_margins"
				when Opcode::SAVE_UNDO then "save_undo"
				when Opcode::RESTORE_UNDO then "restore_undo"
				when Opcode::PRINT_UNICODE then "print_unicode"
				when Opcode::CHECK_UNICODE then "check_unicode"
				when Opcode::MOVE_WINDOW then "move_window"
				when Opcode::WINDOW_SIZE then "window_size"
				when Opcode::WINDOW_STYLE then "window_style"
				when Opcode::GET_WIND_PROP then "get_wind_prop"
				when Opcode::SCROLL_WINDOW then "scroll_window"
				when Opcode::POP_STACK then "pop_stack"
				when Opcode::READ_MOUSE then "read_mouse"
				when Opcode::MOUSE_WINDOW then "mouse_window"
				when Opcode::PUSH_STACK then "push_stack"
				when Opcode::PUT_WIND_PROP then "put_wind_prop"
				when Opcode::PRINT_FORM then "print_form"
				when Opcode::MAKE_MENU then "make_menu"
				when Opcode::PICTURE_TABLE then "picture_table"
				end
			end
		end
	end
end
