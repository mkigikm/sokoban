#!/usr/bin/env ruby

require './sokoban_level.rb'
require 'dispel'

class SokoDisplay
  def initialize(level)
    @level = level
  end

  def level_string
    status = @level.win? ? "Win" : ""
    "#{@level.to_s}\n#{status}\n#{history_string}"
  end

  def history_string
    @level.history.map do |(dir, push)|
      char = case dir
      when :up    then "u"
      when :down  then "d"
      when :left  then "l"
      when :right then "r"
      end

      push ? char.upcase : char
    end.join("").gsub(/(.{10})/, "\\1\n")
  end

  def display_level(screen)
    screen.draw level_string
  end

  def run
    Dispel::Screen.open do |screen|
      display_level(screen)

      Dispel::Keyboard.output do |key|
        case key
        when "q" then break
        when "r" then @level.restart
        when "u" then @level.undo
        when :left then @level.move(:left)
        when :right then @level.move(:right)
        when :up then @level.move(:up)
        when :down then @level.move(:down)
        end
        display_level(screen)
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  level = SokoLevel.from_file(ARGV.shift)
  display = SokoDisplay.new(level)
  display.run
end
