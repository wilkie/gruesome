# encoding: utf-8
#
# DO NOT REMOVE ABOVE COMMENT! IT IS MAGIC!

module Gruesome
	module Logo
		# I'm just making sure this works regardless of the unicode format this
		# source file is saved as...
		LOGO = <<ENDLOGO
        ▄▄▄▄▄                                               ▄▄▄▄▄                       
         ▀████▄                                           ▄████▀                     
           ▀████▄                                       ▄████▀                       
  ▄▄▄▄▄▄    ██████▄   ▄▄▄   ▄▄▄   ▄▄▄▄▄▄   ▄▄▄▄▄▄     ▄████▀  ▄▄▄   ▄▄▄   ▄▄▄▄▄▄
▄████████▄  ██▓▀████▄ ██▓   ███ ▄███████ ▄████████▄ ▄████▀██▄ ████▄████ ▄███████
██▓    ███  ██▓  ▀███ ██▓   ███ ██▓      ██▓    ███ ███▀  ███ █████████ ██▓
██▓         ██▓   ███ ██▓   ███ ██▓      ██▓        ██▓   ███ ███▀█▀███ ██▓
██▓  █████ ████████   ███   ███ ████████ ▀███████▄  ██▓   ███ ██▓   ███ ████████
██▓  ▀▀███ ▀██▓▀▀▀█▄▄ ███   ███ ███▀▀▀▀▀   ▀▀▀▀▀███ ██▓   ███ ██▓   ███ ███▀▀▀▀▀
██▓    ███  ██▓   ███ ██▓   ███ ██▓      ██▓    ███ ██▓   ███ ███   ███ ██▓
▀████████▀  ██▓   ███ ▀███████▀ ▀███████ ▀████████▀ ▀███████▀ ██▓   ███ ▀███████
  ▀▀▀▀▀▀    ▀▀▀   ▀▀▀   ▀▀▀▀▀     ▀▀▀▀▀▀   ▀▀▀▀▀▀     ▀▀▀▀▀   ▀▀▀   ▀▀▀   ▀▀▀▀▀▀
ENDLOGO

		def Logo.print
			puts LOGO
		end
	end
end
