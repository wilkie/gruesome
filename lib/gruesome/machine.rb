require_relative 'z/machine'

module Gruesome
	class Machine
		def initialize(story_file)
			# Later, detect the type
			#
			# For now, assume Z-Machine

			@machine = Z::Machine.new(story_file)
		end

		def execute
			@machine.execute
		end
	end
end
