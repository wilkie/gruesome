# The Z-Machine, in order to conserve precious space, often encoded in various
# strings a codeword that would inject the word given at a particular place in
# the abbreviation table.

require_relative 'memory'
require_relative 'header'
require_relative 'zscii'

module Gruesome
  module Z
    class AbbreviationTable
      def initialize(memory)
        @memory = memory
        @header = Header.new(@memory.contents)
      end

      def lookup(alphabet, index, translation_alphabet)
        abbrev_index = (32 * (alphabet)) + index
        addr = @header.abbrev_tbl_addr + abbrev_index*2

        # this will yield a word address, which we multiply by 2
        # to get into a byte address
        str_addr = @memory.force_readw(addr)
        str_addr *= 2

        ZSCII.translate(translation_alphabet, @header.version, @memory.force_readzstr(str_addr)[1], nil)
      end
    end
  end
end
