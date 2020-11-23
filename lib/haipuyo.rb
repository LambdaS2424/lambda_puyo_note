# frozen_string_literal: true

class Haipuyo
  def self.load(haipuyo_file)
    pattern_strings = ''
    File.open(haipuyo_file, 'r') do |file|
      text = file.read
      pattern_strings = text.split("\r\n")
    end
    pattern_strings
  end
end
