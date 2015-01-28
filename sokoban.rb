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
    @level.history.map do |direction|
      case direction
      when :up    then "U"
      when :down  then "D"
      when :left  then "L"
      when :right then "R"
      end
    end.join("").gsub(/(.{10})/, "\\1\n")
  end

  def run
    Dispel::Screen.open do |screen|
      screen.draw level_string

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
        screen.draw level_string
      end

      screen.draw level_string
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  level = SokoLevel.from_file(ARGV.shift)
  display = SokoDisplay.new(level)
  display.run
end
