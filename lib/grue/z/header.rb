require 'bit-struct'

module Grue
	module Z

		# Z-Story File Header
		class Header < BitStruct
			default_options :endian => :big

			unsigned :version, 8, "Z-Machine Version"
			unsigned :availablity_flags, 8, "Availability Flags"
			unsigned :reservedw1, 16, "Reserved Word 1"
			unsigned :high_mem_base, 16, "High Memory Base"
			unsigned :entry, 16, "Entry Point"
			unsigned :dictionary_addr, 16, "Address of Dictionary"
			unsigned :object_tbl_addr, 16, "Address of Object Table"
			unsigned :global_var_addr, 16, "Address of Global Variables Table"
			unsigned :static_mem_base, 16, "Static Memory Base"
			unsigned :capability_flags, 8, "Desired Capability Flags"
			unsigned :reservedb1, 8, "Reserved Byte 1"
			unsigned :reservedw2, 16, "Reserved Word 2"
			unsigned :reservedw3, 16, "Reserved Word 3"
			unsigned :reservedw4, 16, "Reserved Word 4"
			unsigned :abbrev_tbl_addr, 16, "Address of Abbreviations Table"
			unsigned :file_length, 16, "Length of File"
			unsigned :checksum, 16, "Checksum of File"
			unsigned :interpreter_number, 8, "Interpreter Number"
			unsigned :interpreter_version, 8, "Interpreter Version"
			unsigned :screen_height, 8, "Screen Height (in Lines)"
			unsigned :screen_width, 8, "Screen Height (in Characters)"
			unsigned :screen_width_units, 16, "Screen Width (in Units)"
			unsigned :screen_height_units, 16, "Screen Height (in Units)"
			unsigned :font_width, 8, "Font Width (in Units)"
			unsigned :font_height, 8, "Font Height (in Units)"
			unsigned :routines_addr, 16, "Offset to Routines (Divided by 8)"
			unsigned :static_str_addr, 16, "Offset to Static Strings (Divided by 8)"
			unsigned :background_color, 8, "Default Background Color"
			unsigned :foreground_color, 8, "Default Foreground Color"
			unsigned :terminating_chars_tbl_addr, 16, "Address of Terminating Characters Table"
			unsigned :output_stream_3_width, 16, "Total Width of Characters Send to Output Stream 3"
			unsigned :revision_number, 16, "Standard Revision Number"
			unsigned :alphabet_tbl_addr, 16, "Address of Alphabet Table"
			unsigned :header_ext_tbl_addr, 16, "Address of Header Extension Table"
		end
	end
end
