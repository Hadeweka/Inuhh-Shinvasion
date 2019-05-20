class StdTextField < TextInput

  def initialize(window, font, x, y, start_text, color, size, input)
    super()
    @window, @font, @x, @y = window, font, x, y
    self.text = start_text
    @color = color
    @size = size
    @input = input
  end

  def filter(text)
    return text
    # Return filters for text here
  end

  def draw
    pos_x = @x + @font.text_width(@input, @size) + @font.text_width(self.text[0...self.caret_pos], @size)
    @window.draw_line(pos_x, @y, @color, pos_x, @y + @size*20, @color, 0) if milliseconds % 1000 < 500
    @font.draw(@input + self.text, @x, @y, ZOrder::UI, @size, @size, @color)
  end

end