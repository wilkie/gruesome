require_relative 'gruesome/machine'

module Gruesome
  def Gruesome.execute(story_file)
    Machine.new(story_file).execute
  end
end
