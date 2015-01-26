#!/usr/bin/env ruby

require './sokoban_level.rb'
require 'dispel'

class SokobanDisplay
  def initialize(level)
    @level = level
  end

  def run
    Dispel::Screen.open do |screen|
      screen.draw @level.to_s

      Dispel::Keyboard.output do |key|
        case key
        when "q" then break
        when :left then @level.left
        when :right then @level.right
        when :up then @level.up
        when :down then @level.down
        end
        screen.draw(@level.to_s)
      end

      screen.draw(@level.to_s)
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  level = SokobanLevel.from_file(ARGV.shift)
  display = SokobanDisplay.new(level)
  display.run
end
