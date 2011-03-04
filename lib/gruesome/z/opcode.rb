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
	end
end
