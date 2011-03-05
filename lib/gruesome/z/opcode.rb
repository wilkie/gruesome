module Gruesome
	module Z
		module Opcode
			JE				= 0x01
			JL				= 0x02
			JG				= 0x03
			DEC_CHK			= 0x04
			INC_CHK			= 0x05
			JIN				= 0x06
			TEST			= 0x07
			OR				= 0x08
			AND				= 0x09
			TEST_ATTR		= 0x0a
			SET_ATTR		= 0x0b
			CLEAR_ATTR		= 0x0c
			STORE			= 0x0d
			INSERT_OBJ		= 0x0e
			LOADW			= 0x0f
			LOADB			= 0x10
			GET_PROP		= 0x11
			GET_PROP_ADDR	= 0x12
			GET_NEXT_PROP	= 0x13
			ADD				= 0x14
			SUB				= 0x15
			MUL				= 0x16
			DIV				= 0x17
			MOD				= 0x18
			CALL_2S			= 0x19
			CALL_2N			= 0x1a
			SET_COLOUR		= 0x1b
			THROW			= 0x1c

			# 1OP

			JZ				= 0x00
			GET_SIBLING		= 0x01
			GET_CHILD		= 0x02
			GET_PARENT		= 0x03
			GET_PROP_LEN	= 0x04
			INC				= 0x05
			DEC				= 0x06
			PRINT_ADDR		= 0x07
			CALL_1S			= 0x08
			REMOVE_OBJ		= 0x09
			PRINT_OBJ		= 0x0a
			RET				= 0x0b
			JUMP			= 0x0c
			PRINT_PADDR		= 0x0d
			LOAD			= 0x0e
			NOT				= 0x0f # version 1-4
			CALL_1N			= 0x0f # version 5

			# 0OP
			
			RTRUE			= 0x00
			RFALSE			= 0x01
			PRINT			= 0x02
			PRINT_RET		= 0x03
			NOP				= 0x04
			SAVE			= 0x05
			RESTORE			= 0x06
			RESTART			= 0x07
			RET_POPPED		= 0x08
			POP				= 0x09 # version 1
			CATCH			= 0x09 # version 5/6
			QUIT			= 0x0a
			NEW_LINE		= 0x0b
			SHOW_STATUS		= 0x0c # version 3
			VERIFY			= 0x0d # version 3
			EXTENDED		= 0x0e
			PIRACY			= 0x0f # version 5/-

			# VAR

			CALL			= 0x00 # version 1
			CALL_VS			= 0x00 # version 4
			STOREW			= 0x01
			STOREB			= 0x02
			PUT_PROP		= 0x03
			SREAD			= 0x04 # version 1 (4 changes semantics)
			AREAD			= 0x04 # version 5
			PRINT_CHAR		= 0x05
			PRINT_NUM		= 0x06
			RANDOM			= 0x07
			PUSH			= 0x08
			PULL			= 0x09
			SPLIT_WINDOW	= 0x0a
			SET_WINDOW		= 0x0b
			CALL_VS2		= 0x0c
			ERASE_WINDOW	= 0x0d
			ERASE_LINE		= 0x0e
			SET_CURSOR		= 0x0f
			GET_CURSOR		= 0x10
			SET_TEXT_STYLE	= 0x11
			BUFFER_MODE		= 0x12
			OUTPUT_STREAM	= 0x13
			INPUT_STREAM	= 0x14
			SOUND_EFFECT	= 0x15
			READ_CHAR		= 0x16
			SCAN_TABLE		= 0x17
			NOT_2			= 0x18 # version 5/6
			CALL_VN			= 0x19
			CALL_VN2		= 0x1a
			TOKENIZE		= 0x1b
			ENCODE_TEXT		= 0x1c
			COPY_TABLE		= 0x1d
			PRINT_TABLE		= 0x1e
			CHECK_ARG_COUNT	= 0x1f

			EXT_SAVE		= 0x00
			EXT_RESTORE		= 0x01
			EXT_LOG_SHIFT	= 0x02
			EXT_ART_SHIFT	= 0x03
			EXT_SET_FONT	= 0x04
			EXT_DRAW_PICTURE = 0x05
			EXT_PICTURE_DATA = 0x06
			EXT_ERASE_PICTURE = 0x07
			EXT_SET_MARGINS	= 0x08
			EXT_SAVE_UNDO	= 0x09
			EXT_RESTORE_UNDO = 0x0a
			EXT_PRINT_UNICODE = 0x0b
			EXT_CHECK_UNICODE = 0x0c
			EXT_MOVE_WINDOW = 0x10
			EXT_WINDOW_SIZE = 0x11
			EXT_WINDOW_STYLE = 0x12
			EXT_GET_WIND_PROP = 0x13
			EXT_SCROLL_WINDOW = 0x14
			EXT_POP_STACK = 0x15
			EXT_READ_MOUSE = 0x16
			EXT_MOUSE_WINDOW = 0x17
			EXT_PUSH_STACK = 0x18
			EXT_PUT_WIND_PROP = 0x19
			EXT_PRINT_FORM	= 0x1a
			EXT_MAKE_MENU	= 0x1b
			EXT_PICTURE_TABLE = 0x1c
		end

		def Opcode.is_store?(opcode_class, opcode, version)
			result = false
			if opcode_class == OpcodeClass::OP2
				case opcode
				when Opcode::OR, Opcode::AND, Opcode::LOADB, Opcode::LOADW,
					Opcode::GET_PROP, Opcode::GET_PROP_ADDR, Opcode::GET_NEXT_PROP,
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
				when Opcode::SAVE, Opcode::RESTORE, Opcode::CATCH,
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

		def Opcode.is_valid?(opcode_class, opcode, version)
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
				when Opcode::SET_TEXT_STYLE
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
				when Opcode::EXT_SAVE_TABLE, EXT_RESTORE_TABLE, EXT_LOG_SHIFT,
						EXT_ART_SHIFT, EXT_SET_FONT, EXT_SAVE_UNDO, EXT_RESTORE_UNDO,
						EXT_PRINT_UNICODE, EXT_CHECK_UNICODE
				else
					result = false if version < 6
				end
			end
			result
		end

		def Opcode.is_branch?(opcode_class, opcode, version)
			if is_valid?(opcode_class, opcode, version)
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
				when Opcode::EXT_PICTURE_DATA, 
						Opcode::PUSH_STACK, Opcode::MAKE_MENU
					result = true
				end
			end

			result
		end

		def Opcode.name(opcode_class, opcode, version)
			if not is_valid?(opcode_class, opcode, version)
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
				when Opcode::POP, CATCH
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
				when Opcode::GET_NEXT_PROP then "get_next_prop"
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
				when Opcode::CALL, CALL_VS
					if version < 4
						"call"
					else
						"call_vs"
					end
				when Opcode::STOREW then "storew"
				when Opcode::STOREB then "storeb"
				when Opcode::PUT_PROP then "put_prop"
				when Opcode::SREAD, AREAD
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
				when Opcode::SET_TEXT_STYLE then "set_text_style"
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
				when Opcode::EXT_SAVE_TABLE then "save_table"
				when Opcode::EXT_RESTORE_TABLE then "restore_table"
				when Opcode::EXT_LOG_SHIFT then "log_shift"
				when Opcode::EXT_ART_SHIFT then "art_shift"
				when Opcode::EXT_SET_FONT then "set_font"
				when Opcode::EXT_DRAW_PICTURE then "draw_picture"
				when Opcode::EXT_PICTURE_DATA then "picture_data"
				when Opcode::EXT_ERASE_PICTURE then "erase_picture"
				when Opcode::EXT_SET_MARGINS then "set_margins"
				when Opcode::EXT_SAVE_UNDO then "save_undo"
				when Opcode::EXT_RESTORE_UNDO then "restore_undo"
				when Opcode::EXT_PRINT_UNICODE then "print_unicode"
				when Opcode::EXT_CHECK_UNICODE then "check_unicode"
				when Opcode::EXT_MOVE_WINDOW then "move_window"
				when Opcode::EXT_WINDOW_SIZE then "window_size"
				when Opcode::EXT_WINDOW_STYLE then "window_style"
				when Opcode::EXT_GET_WIND_PROP then "get_wind_prop"
				when Opcode::EXT_SCROLL_WINDOW then "scroll_window"
				when Opcode::EXT_POP_STACK then "pop_stack"
				when Opcode::EXT_READ_MOUSE then "read_mouse"
				when Opcode::EXT_MOUSE_WINDOW then "mouse_window"
				when Opcode::EXT_PUSH_STACK then "push_stack"
				when Opcode::EXT_PUT_WIND_PROP then "put_wind_prop"
				when Opcode::EXT_PRINT_FORM then "print_form"
				when Opcode::EXT_MAKE_MENU then "make_menu"
				when Opcode::EXT_PICTURE_TABLE then "picture_table"
				end
			end
		end
	end
end
